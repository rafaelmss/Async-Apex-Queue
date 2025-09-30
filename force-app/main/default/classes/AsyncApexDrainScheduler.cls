global with sharing class AsyncApexDrainScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        System.enqueueJob(new AsyncApexDrainJob());
    }
}