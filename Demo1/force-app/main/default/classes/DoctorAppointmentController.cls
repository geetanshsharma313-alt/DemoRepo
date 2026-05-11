public without sharing class DoctorAppointmentController {

   
    public static final Integer SLOT_DURATION_MIN = 30;
    private static final Integer CLINIC_START_HOUR = 9;
    private static final Integer CLINIC_END_HOUR = 17;

    
    @AuraEnabled(cacheable=true)
    public static Id getCurrentUserContactId() {
        User u = [
            SELECT ContactId
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        return u.ContactId;
    }

    
    @AuraEnabled(cacheable=true)
    public static List<String> getSpecialities() {
        List<String> values = new List<String>();

        for (AggregateResult ar : [
            SELECT Speciality__c sp
            FROM Contact
            WHERE Speciality__c != null
            GROUP BY Speciality__c
            ORDER BY Speciality__c
        ]) {
            values.add((String) ar.get('sp'));
        }
        return values;
    }

   
    @AuraEnabled(cacheable=true)
    public static List<Contact> getDoctorsBySpeciality(String speciality) {
        return [
            SELECT Id, Name, Speciality__c, Phone, Email
            FROM Contact
            WHERE Speciality__c = :speciality
            ORDER BY Name
        ];
    }

    
    @AuraEnabled(cacheable=true)
    public static List<TimeSlotWrapper> getAvailableSlots(
        Id doctorId,
        String appointmentDate
    ) {
        Date apptDate = Date.valueOf(appointmentDate);

        if (apptDate < Date.today()) {
            throw new AuraHandledException('Appointments cannot be booked for past dates.');
        }

        Set<Time> bookedSlots = getBookedSlots(doctorId, apptDate);
        return generateSlots(bookedSlots);
    }

    private static Set<Time> getBookedSlots(Id doctorId, Date apptDate) {
        Set<Time> booked = new Set<Time>();

        for (Doctor_Appointment__c appt : [
            SELECT Start_Time__c
            FROM Doctor_Appointment__c
            WHERE Doctor__c = :doctorId
              AND Appointment_Date__c = :apptDate
              AND Appointment_Status__c != 'Cancelled'
        ]) {
            booked.add(appt.Start_Time__c);
        }
        return booked;
    }

    private static List<TimeSlotWrapper> generateSlots(Set<Time> bookedSlots) {
        List<TimeSlotWrapper> slots = new List<TimeSlotWrapper>();

        Time current = Time.newInstance(CLINIC_START_HOUR, 0, 0, 0);
        Time clinicEnd = Time.newInstance(CLINIC_END_HOUR, 0, 0, 0);

        while (current < clinicEnd) {
            TimeSlotWrapper slot = new TimeSlotWrapper();
            slot.timeValue = current;
            slot.displayTime = formatTime(current);
            slot.isAvailable = !bookedSlots.contains(current);
            slots.add(slot);

            current = current.addMinutes(SLOT_DURATION_MIN);
        }
        return slots;
    }

    
    @AuraEnabled
    public static String bookAppointment(
        Id patientContactId,
        Id doctorId,
        String appointmentDate,
        String startTime, // MUST be HH:mm
        String symptoms,
        String notes
    ) {
        if (patientContactId == null) {
            throw new AuraHandledException('Please ensure your user is linked to a Contact.');
        }

        Date apptDate = Date.valueOf(appointmentDate);
        Time startT = parseTime(startTime);
        Time endT = startT.addMinutes(SLOT_DURATION_MIN);

        Doctor_Appointment__c appt = new Doctor_Appointment__c(
            Patient__c = patientContactId,
            Doctor__c = doctorId,
            Appointment_Date__c = apptDate,
            Start_Time__c = startT,
            End_Time__c = endT,
            Appointment_Status__c = 'Requested'
        );

        insert appt;
        return appt.Id;
    }

    
    @AuraEnabled(cacheable=true)
    public static List<Doctor_Appointment__c> getUpcomingAppointments() {
        Id contactId = [
            SELECT ContactId
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ].ContactId;

        if (contactId == null) {
            return new List<Doctor_Appointment__c>();
        }

        return [
            SELECT Id,
       Appointment_Date__c,
       Start_Time__c,
       End_Time__c,
       Appointment_Status__c,
       Doctor__r.Name,
       Doctor__r.Speciality__c
FROM Doctor_Appointment__c
WHERE Patient__c = :contactId
  AND Appointment_Date__c >= :Date.today()
  AND Appointment_Status__c != 'Cancelled'
ORDER BY Appointment_Date__c, Start_Time__c
LIMIT 7
        ];
    }

    
    private static Time parseTime(String timeStr) {
        List<String> p = timeStr.split(':');
        return Time.newInstance(
            Integer.valueOf(p[0]),
            Integer.valueOf(p[1]),
            0, 0
        );
    }

    private static String formatTime(Time t) {
        Integer h = t.hour();
        Integer m = t.minute();
        String ampm = h >= 12 ? 'PM' : 'AM';
        h = h > 12 ? h - 12 : (h == 0 ? 12 : h);

        return h + ':' +
            (m < 10 ? '0' + m : String.valueOf(m)) +
            ' ' + ampm;
    }

    public class TimeSlotWrapper {
        @AuraEnabled public Time timeValue;
        @AuraEnabled public String displayTime;
        @AuraEnabled public Boolean isAvailable;
    }
}