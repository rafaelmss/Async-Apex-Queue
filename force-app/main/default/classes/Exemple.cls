public class Exemple {
    
    // execute a cenario exemple
    public Static void execute(){
        
        // generate 100 elements do execute like Apex and 100 like Batch
        // this exemplify how submit element to queue
        for(Integer i=0; i<100; i++){
        	String payload = '{"data":"Test ' + String.ValueOf(i) + '"}';
            AsyncApexFramework.submitApex(new ApexDemo(), i, true, payload);
        }
        AsyncApexFramework.flush();

        // start schedules to run each 10 minutes
        Integer everyNthMinute = 10;
        String nameOfSchedulableClass = 'AsyncApexDrainScheduler';
        Integer counter = 1;
        for(Integer minute=0;minute<60;minute++){
            if(Math.mod(minute,everyNthMinute)==0){
                String scheduleName = nameOfSchedulableClass + String.valueOf(counter);
                String cronPattern  = '0 '+ String.valueOf(minute) +' * * * ?';
                System.schedule(scheduleName,cronPattern, (Schedulable)Type.forName(nameOfSchedulableClass).newInstance());
                counter++;
            }
        }
    }
}