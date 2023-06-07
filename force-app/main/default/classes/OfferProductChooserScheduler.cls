global class OfferProductChooserScheduler implements schedulable{

    private Integer yearsPerBatch = 1;

    global void execute(SchedulableContext sc){
        OfferProductChooserBatch hondaBatch = new OfferProductChooserBatch('Honda', 'A','New');
        OfferProductChooserBatch hondaBatch_used = new OfferProductChooserBatch('Honda', 'A','used');
        OfferProductChooserBatch acuraBatch = new OfferProductChooserBatch('Acura', 'B','New');   
        OfferProductChooserBatch acuraBatch_used = new OfferProductChooserBatch('Acura', 'B','used');            
        OfferProductChooserBatch powersportsBatch = new OfferProductChooserBatch('Powersports', 'M','New');

        ID hondabatchprocessid = Database.executeBatch(hondaBatch, this.yearsPerBatch);
        ID hondabatchUsedprocessid = Database.executeBatch(hondaBatch_used, this.yearsPerBatch);
        ID acurabatchprocessid = Database.executeBatch(acuraBatch, this.yearsPerBatch);
        ID acurabatchUsedprocessid = Database.executeBatch(acuraBatch_used, this.yearsPerBatch);
        ID powersportsbatchprocessid = Database.executeBatch(powersportsBatch, this.yearsPerBatch);
    }
}