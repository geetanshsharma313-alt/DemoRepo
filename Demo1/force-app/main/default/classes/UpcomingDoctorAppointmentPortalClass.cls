public without sharing class UpcomingDoctorAppointmentPortalClass {

    @AuraEnabled(cacheable=true)
    public static List<AppointmentWrapper> getUpcomingAppointments() {

        Id doctorContactId = [
            SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()
        ].ContactId;

        List<AppointmentWrapper> result = new List<AppointmentWrapper>();

        for (Doctor_Appointment__c apt : [
            SELECT Id, Name,
                   Patient__r.Name, Patient__r.Email, Patient__r.Phone,
                   Appointment_Date__c, Start_Time__c, End_Time__c,
                   Appointment_Status__c
            FROM Doctor_Appointment__c
            WHERE Doctor__c = :doctorContactId
        ]) {
            AppointmentWrapper w = new AppointmentWrapper();
            w.appointmentId = apt.Id;
            w.appointmentNumber = apt.Name;
            w.patientName = apt.Patient__r.Name;
            w.patientEmail = apt.Patient__r.Email;
            w.patientPhone = apt.Patient__r.Phone;
            w.status = apt.Appointment_Status__c;
            w.formattedDate = String.valueOf(apt.Appointment_Date__c);
            w.formattedTime = apt.Start_Time__c + ' - ' + apt.End_Time__c;

            if (w.status == 'Confirmed') w.statusBadgeClass = 'status-pill status-confirmed';
            else if (w.status == 'Requested') w.statusBadgeClass = 'status-pill status-requested';
            else if (w.status == 'Cancelled') w.statusBadgeClass = 'status-pill status-cancelled';
            else w.statusBadgeClass = 'status-pill';

            result.add(w);
        }
        return result;
    }

    @AuraEnabled
    public static void updateAppointmentStatus(Id appointmentId, String newStatus) {
        update new Doctor_Appointment__c(
            Id = appointmentId,
            Appointment_Status__c = newStatus
        );
    }

    public class AppointmentWrapper {
        @AuraEnabled public Id appointmentId;
        @AuraEnabled public String appointmentNumber;
        @AuraEnabled public String patientName;
        @AuraEnabled public String patientEmail;
        @AuraEnabled public String patientPhone;
        @AuraEnabled public String status;
        @AuraEnabled public String formattedDate;
        @AuraEnabled public String formattedTime;
        @AuraEnabled public String statusBadgeClass;
    }
}