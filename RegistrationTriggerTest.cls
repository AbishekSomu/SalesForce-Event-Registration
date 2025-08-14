@isTest
private class RegistrationTriggerTest {
    @isTest static void testPreventOverbooking() {
        Custom_Event__c ev = new Custom_Event__c(Name='Test Event', Date__c=Date.today().addDays(10), Organizer__c='Org', Max_Participants__c=2);
        insert ev;

        Student__c s1 = new Student__c(Name='Stu One', Email__c='s1@example.com', Department__c='CS');
        Student__c s2 = new Student__c(Name='Stu Two', Email__c='s2@example.com', Department__c='EC');
        Student__c s3 = new Student__c(Name='Stu Three', Email__c='s3@example.com', Department__c='ME');
        insert new List<Student__c>{s1,s2,s3};

        Registration__c r1 = new Registration__c(Name='Reg1', Student__c=s1.Id, Event__c=ev.Id, Registration_Date__c=Date.today());
        Registration__c r2 = new Registration__c(Name='Reg2', Student__c=s2.Id, Event__c=ev.Id, Registration_Date__c=Date.today());
        insert new List<Registration__c>{r1, r2};

        Registration__c r3 = new Registration__c(Name='Reg3', Student__c=s3.Id, Event__c=ev.Id, Registration_Date__c=Date.today());

        try {
            insert r3;
            System.assert(false, 'Expected DML exception due to max participants being reached');
        } catch (DmlException ex) {
            System.assert(ex.getMessage().contains('Cannot register'), 'Unexpected exception: ' + ex.getMessage());
        }
    }

    @isTest static void testValidationRuleRegistrationDate() {
        Custom_Event__c ev = new Custom_Event__c(Name='EventDateTest', Date__c=Date.today().addDays(1), Organizer__c='Org', Max_Participants__c=10);
        insert ev;

        Student__c s = new Student__c(Name='Date Stu', Email__c='date@example.com', Department__c='CS');
        insert s;

        Registration__c bad = new Registration__c(Name='BadReg', Student__c=s.Id, Event__c=ev.Id, Registration_Date__c=Date.today().addDays(2));

        try {
            insert bad;
            System.assert(false, 'Expected validation rule to prevent registration with date after event');
        } catch (DmlException ex) {
            System.assert(ex.getMessage().contains('Registration date must be before the Event date') 
                          || ex.getMessage().contains('Registration date must be before'), 'Unexpected exception: ' + ex.getMessage());
        }
    }

    @isTest static void testBulkRegistrationEdgeCase() {
        Custom_Event__c ev = new Custom_Event__c(Name='BulkEvent', Date__c=Date.today().addDays(5), Organizer__c='Org', Max_Participants__c=3);
        insert ev;

        List<Student__c> studs = new List<Student__c>();
        for (Integer i=0;i<5;i++) {
            studs.add(new Student__c(Name='Bulk' + i, Email__c='bulk'+i+'@ex.com', Department__c='CS'));
        }
        insert studs;

        List<Registration__c> regs = new List<Registration__c>();
        for (Integer i=0;i<5;i++) {
            regs.add(new Registration__c(Name='BR'+i, Student__c=studs[i].Id, Event__c=ev.Id, Registration_Date__c=Date.today()));
        }

        try {
            insert regs;
            System.assert(false, 'Expected DML exception when bulk inserting over limit');
        } catch (DmlException ex) {
            System.assert(ex.getMessage().contains('Cannot register'));
        }
    }
}