public with sharing class AsyncApexFramework {

    enum Kind { Batch, Apex }

    private static List<Request> buffer = new List<Request>();

    public static Id submitApex(IAsyncApex instance,
                                     Integer priority,
                                     Boolean allowRetry,
                               		 String payload) {
        buffer.add(Request.forApex(instance, priority, allowRetry, payload));
        return null;
    }

    public static void flush() {
        if (buffer.isEmpty()) return;

        buffer.sort();

        if (!buffer.isEmpty()) {
            List<AsyncJob__c> inserts = new List<AsyncJob__c>();
            for (Request r : buffer) {
                inserts.add(r.toRecord(null));
            }
            insert inserts;
        }

        buffer.clear();
    }
    
    public static Request forApex(IAsyncApex inst, Integer prio, Boolean retry, String payload) {
        Request r = new Request();
        r.kind = AsyncApexFramework.Kind.Apex;
        r.apexInstance = inst;
        r.priority = prio != null ? prio : 99;
        r.allowRetry = (retry == null) ? false : retry;
        r.payloadJson = payload;
        return r;
    }

    private class Request implements Comparable {

        Kind kind;
        Integer priority;
        Boolean allowRetry;
        IAsyncApex apexInstance;
        String apexClassName;
        String payloadJson;

        void persistWithError(Exception e) {
            insert toRecord(e.getMessage());
        }

        AsyncJob__c toRecord(String lastError) {
            AsyncJob__c rec = new AsyncJob__c();
            rec.Status__c = 'Pending';
            rec.ApexClassName__c = apexClassName != null ? apexClassName : inferClassName();
            rec.Payload__c = payloadJson;
            rec.Priority__c = priority;
            rec.AllowRetry__c = allowRetry;
            rec.RetryCount__c = 0;
            rec.MaxRetries__c = 3;
            if (lastError != null) rec.LastError__c = lastError;
            return rec;
        }

        public Integer compareTo(Object o) {
            Request other = (Request) o;
            Integer a = (this.priority == null) ? 99 : this.priority;
            Integer b = (other.priority == null) ? 99 : other.priority;
            if (a == b) return 0;
            return (a < b) ? -1 : 1;
        }

        private String inferClassName() {
            if (apexInstance != null) return String.valueOf(apexInstance).split(':')[0];
            return null;
        }
    }
}