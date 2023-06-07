global class guestUserCleanupBatchSchedule2 implements Schedulable {

        global void execute(SchedulableContext sc) {
        guestUserCleanupBatch2 guc=new guestUserCleanupBatch2();
        Database.executeBatch(guc,50);
        
    }
}