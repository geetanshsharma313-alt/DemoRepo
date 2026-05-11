import { LightningElement } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

export default class ScAppointmentCalendar extends LightningElement {

    initialized = false;

    renderedCallback() {
        if (this.initialized) return;
        this.initialized = true;

        Promise.all([
            // CORE CSS
            loadStyle(this, 'https://cdn.jsdelivr.net/npm/fullcalendar@4.4.2/core/main.min.css'),
            // VIEW CSS
            loadStyle(this, 'https://cdn.jsdelivr.net/npm/fullcalendar@4.4.2/daygrid/main.min.css'),
            loadStyle(this, 'https://cdn.jsdelivr.net/npm/fullcalendar@4.4.2/timegrid/main.min.css'),

            // CORE JS
            loadScript(this, 'https://cdn.jsdelivr.net/npm/fullcalendar@4.4.2/core/main.min.js'),
            // PLUGINS
            loadScript(this, 'https://cdn.jsdelivr.net/npm/fullcalendar@4.4.2/interaction/main.min.js'),
            loadScript(this, 'https://cdn.jsdelivr.net/npm/fullcalendar@4.4.2/daygrid/main.min.js'),
            loadScript(this, 'https://cdn.jsdelivr.net/npm/fullcalendar@4.4.2/timegrid/main.min.js')
        ])
        .then(() => {
            this.initializeCalendar();
        })
        .catch(error => {
            console.error('FullCalendar load failed', error);
        });
    }

    initializeCalendar() {
        const calendarEl = this.template.querySelector('.calendar');

        const calendar = new window.FullCalendar.Calendar(calendarEl, {
            plugins: ['interaction', 'dayGrid', 'timeGrid'],
            defaultView: 'timeGridWeek',   // 🔥 v4 uses defaultView
            height: 700,
            allDaySlot: false,
            selectable: true,
            nowIndicator: true,
            slotDuration: '00:30:00',
            slotLabelInterval: '01:00',
            slotMinTime: '09:00:00',
            slotMaxTime: '18:00:00',
            header: {
                left: 'prev,next today',
                center: 'title',
                right: 'timeGridDay,timeGridWeek,dayGridMonth'
            },
            dateClick: function(info) {
                alert('Selected: ' + info.dateStr);
            }
        });

        calendar.render();
    }
}