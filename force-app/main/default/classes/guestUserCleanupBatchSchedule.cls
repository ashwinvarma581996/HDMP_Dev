global class guestUserCleanupBatchSchedule implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        guestUserCleanupBatch guc=new guestUserCleanupBatch();
        Database.executeBatch(guc,50);
        
    }
}