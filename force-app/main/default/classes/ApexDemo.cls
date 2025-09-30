public class ApexDemo implements IAsyncApex{
    
    public void execute(String payload){
        // your logic
        System.debug(payload);
    }
    
    public String toClassNameString() { return 'ApexDemo'; }
}