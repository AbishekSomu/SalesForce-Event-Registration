public with sharing class RegistrationTriggerHandler {
    public static void preventOverbookedEvents(List<Registration__c> newRegs, Map<Id, Registration__c> oldMap) {
        Map<Id, Integer> newCountByEvent = new Map<Id, Integer>();
        Set<Id> eventIds = new Set<Id>();

        for (Registration__c r : newRegs) {
            if (r.Event__c != null) {
                eventIds.add(r.Event__c);
                newCountByEvent.put(
                    r.Event__c,
                    newCountByEvent.get(r.Event__c) == null ? 1 : newCountByEvent.get(r.Event__c) + 1
                );
            }
        }
        if (eventIds.isEmpty()) return;

        // Query Custom_Event__c instead of Event__c
        Map<Id, Custom_Event__c> events = new Map<Id, Custom_Event__c>(
            [SELECT Id, Max_Participants__c FROM Custom_Event__c WHERE Id IN :eventIds FOR UPDATE]
        );

        AggregateResult[] grouped = [
            SELECT Event__c ev, COUNT(Id) cnt
            FROM Registration__c
            WHERE Event__c IN :eventIds
            GROUP BY Event__c
        ];
        Map<Id, Integer> existingCount = new Map<Id, Integer>();
        for (AggregateResult ar : grouped) {
            existingCount.put((Id)ar.get('ev'), (Integer)ar.get('cnt'));
        }

        Map<Id, Integer> netAdditions = new Map<Id, Integer>();
        for (Registration__c r : newRegs) {
            Id evtId = r.Event__c;
            if (evtId == null) continue;

            Boolean countsAsNew = true;

            if (oldMap != null && oldMap.containsKey(r.Id)) {
                Registration__c oldR = oldMap.get(r.Id);
                if (oldR.Event__c == evtId) {
                    countsAsNew = false;
                }
            }

            if (countsAsNew) {
                netAdditions.put(evtId, netAdditions.get(evtId) == null ? 1 : netAdditions.get(evtId) + 1);
            }
        }

        for (Registration__c r : newRegs) {
            if (r.Event__c == null) continue;
            Custom_Event__c e = events.get(r.Event__c);
            if (e == null) continue;

            Integer existing = existingCount.get(r.Event__c) == null ? 0 : existingCount.get(r.Event__c);
            Integer netAdd = netAdditions.get(r.Event__c) == null ? 0 : netAdditions.get(r.Event__c);

            Integer allowed = (e.Max_Participants__c == null) ? 2147483647 : Integer.valueOf(e.Max_Participants__c);

            if (existing + netAdd > allowed) {
                r.addError('Cannot register: maximum participants reached for this event.');
            }
        }
    }
}