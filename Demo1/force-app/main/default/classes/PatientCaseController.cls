public without sharing class PatientCaseController {

    /* ===================== FETCH APPOINTMENTS ===================== */
    @AuraEnabled(cacheable=true)
    public static List<Doctor_Appointment__c> getMyAppointments() {

        User u = [
            SELECT ContactId
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];

        if (u.ContactId == null) {
            return new List<Doctor_Appointment__c>();
        }

        return [
            SELECT Id,
                   Doctor__c,
                   Doctor__r.Name,
                   Appointment_Date__c,
                   Start_Time__c
            FROM Doctor_Appointment__c
            WHERE Patient__c = :u.ContactId
            ORDER BY Appointment_Date__c DESC 
        ];
    }

    /* ===================== CREATE CASE ===================== */
    @AuraEnabled
    public static Id createCase(
        String problemRelatedTo,
        String subject,
        String description,
        Id appointmentId,
        Id providerId
    ) {

        /* 1️⃣ Get logged-in user's Contact and Account */
        User u = [
            SELECT ContactId, Contact.AccountId
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];

        if (u.ContactId == null) {
            throw new AuraHandledException(
                'Your user is not linked to a Contact.'
            );
        }

        /* 2️⃣ Fetch Patient Support Case Record Type */
        List<RecordType> rts = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Case'
            AND DeveloperName = 'Patient_Support'
            LIMIT 1
        ];

        if (rts.isEmpty()) {
            throw new AuraHandledException(
                'Patient Support Case record type not found. Please contact administrator.'
            );
        }

        /* 3️⃣ Create Case */
        Case c = new Case();
        c.RecordTypeId = rts[0].Id;
        c.ContactId = u.ContactId;
        c.Subject = subject;
        c.Description = description;
        c.Origin = 'Patient Portal';

        // Custom fields
        c.Problem_Related_To__c = problemRelatedTo;
        c.Provider__c = providerId;
        c.Doctor_Appointment__c = appointmentId;

        /* 4️⃣ Attach Entitlement */
        if (u.Contact != null && u.Contact.AccountId != null) {

            List<Entitlement> entRecords = [
                SELECT Id
                FROM Entitlement
                WHERE AccountId = :u.Contact.AccountId
                AND Status = 'Active'
                AND Type = 'Web Support'
                LIMIT 1
            ];

            if (!entRecords.isEmpty()) {
                c.EntitlementId = entRecords[0].Id;
            }
        }

        insert c;
        return c.Id;
    }

//     /* ===================== FETCH DOCTOR APPOINTMENTS ===================== */
// @AuraEnabled(cacheable=true)
// public static List<Doctor_Appointment__c> getDoctorAppointments() {

//     User u = [
//         SELECT ContactId
//         FROM User
//         WHERE Id = :UserInfo.getUserId()
//         LIMIT 1
//     ];

//     if (u.ContactId == null) {
//         return new List<Doctor_Appointment__c>();
//     }

//     return [
//         SELECT Id,
//                Patient__r.Name,
//                Appointment_Date__c
//         FROM Doctor_Appointment__c
//         WHERE Doctor__c = :u.ContactId
//         ORDER BY Appointment_Date__c DESC
//     ];
// }


// /* ===================== CREATE PROVIDER SUPPORT CASE ===================== */
// @AuraEnabled
// public static Id createProviderCase(
//     String problemRelatedTo,
//     String subject,
//     String description,
//     Id appointmentId
// ){

//     User u = [
//         SELECT ContactId
//         FROM User
//         WHERE Id = :UserInfo.getUserId()
//         LIMIT 1
//     ];

//     List<RecordType> rts = [
//         SELECT Id
//         FROM RecordType
//         WHERE SObjectType='Case'
//         AND DeveloperName='Provider_Support'
//         LIMIT 1
//     ];

//     Case c = new Case();
//     c.RecordTypeId = rts[0].Id;
//     c.ContactId = u.ContactId;
//     c.Subject = subject;
//     c.Description = description;
//     c.Origin = 'Doctor Portal';

//     c.Problem_Related_To__c = problemRelatedTo;
//     c.Doctor_Appointment__c = appointmentId;

//     insert c;

//     return c.Id;
// }
}