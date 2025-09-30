public with sharing class AsyncApexDrainJob implements Queueable, Database.AllowsCallouts {

    public void execute(QueueableContext qc) {
        Integer holding = [SELECT COUNT() FROM AsyncApexJob WHERE Status = 'Holding'];
        Integer capacity = Math.max(0, 100 - holding);
        if (capacity <= 0) return;

        List<AsyncJob__c> pendingJobList = [
            SELECT Id, Status__c, ApexClassName__c,
                   Payload__c, Priority__c, AllowRetry__c,
                   RetryCount__c, MaxRetries__c
            FROM AsyncJob__c
            WHERE Status__c = 'Pending'
            ORDER BY Priority__c ASC, CreatedDate ASC
            LIMIT :capacity
        ];

        if (pendingJobList.isEmpty()) return;

        List<AsyncJob__c> toUpdate = new List<AsyncJob__c>();

        for (AsyncJob__c job : pendingJobList) {
            try {
                IAsyncApex inst = (IAsyncApex) Type.forName(job.ApexClassName__c).newInstance();
                inst.execute(job.Payload__c);
                job.Status__c = 'Submitted';
                job.LastError__c = null;
                toUpdate.add(job);
            } catch (Exception e) {
                job.RetryCount__c = (job.RetryCount__c == null ? 0 : job.RetryCount__c) + 1;
                job.LastError__c = e.getMessage();
                if (job.AllowRetry__c == true && job.RetryCount__c < (job.MaxRetries__c == null ? 3 : job.MaxRetries__c)) {
                    job.Status__c = 'Pending';
                } else {
                    job.Status__c = 'Failed';
                }
                toUpdate.add(job);
            }
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }
}