global class OwnProductChooserScheduler implements schedulable{

    private Integer yearsPerBatch = 1;

    global void execute(SchedulableContext sc){
        OwnProductChooserBatch hondaBatch = new OwnProductChooserBatch('Honda', 'A');
        OwnProductChooserBatch acuraBatch = new OwnProductChooserBatch('Acura', 'B');
        OwnProductChooserBatch powersportsBatch = new OwnProductChooserBatch('Powersports', 'P');

        ID hondabatchprocessid = Database.executeBatch(hondaBatch, this.yearsPerBatch);
        ID acurabatchprocessid = Database.executeBatch(acuraBatch, this.yearsPerBatch);
        ID powersportsbatchprocessid = Database.executeBatch(powersportsBatch, this.yearsPerBatch);
    }
}