public with sharing class EventRegistrationController {

    @AuraEnabled(cacheable=true)
    public static List<Custom_Event__c> getUpcomingEvents() {
        return [
            SELECT Id, Name, Date__c, Organizer__c, Max_Participants__c
            FROM Custom_Event__c
            WHERE Date__c >= TODAY
            ORDER BY Date__c ASC
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Student__c> getStudents() {
        return [
            SELECT Id, Name
            FROM Student__c
            ORDER BY Name ASC
        ];
    }

    @AuraEnabled
    public static String createRegistration(String regName, Id studentId, Id eventId, Date registrationDate, String email) {
        if (String.isBlank(regName) || studentId == null || eventId == null || registrationDate == null || String.isBlank(email)) {
            throw new AuraHandledException('All fields are required.');
        }

        List<Custom_Event__c> events = [
            SELECT Id, Name, Date__c, Max_Participants__c,
                   (SELECT Id FROM Registrations__r)
            FROM Custom_Event__c
            WHERE Id = :eventId
            LIMIT 1
        ];

        if (events.isEmpty()) {
            throw new AuraHandledException('The selected event does not exist.');
        }

        Custom_Event__c evt = events[0];

        if (evt.Registrations__r.size() >= evt.Max_Participants__c) {
            throw new AuraHandledException('The event has reached its maximum participants.');
        }

        if (registrationDate > evt.Date__c) {
            throw new AuraHandledException('Registration date must be on or before the event date.');
        }

        Registration__c reg = new Registration__c();
        reg.Name = regName;
        reg.Student__c = studentId;
        reg.Event__c = eventId; // updated lookup field
        reg.Registration_Date__c = registrationDate;
        reg.Email__c = email;
        insert reg;

        return 'Registration successful for event: ' + evt.Name;
    }
}
