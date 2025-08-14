import { LightningElement, track, wire } from 'lwc';
import getUpcomingEvents from '@salesforce/apex/EventRegistrationController.getUpcomingEvents';
import getStudents from '@salesforce/apex/EventRegistrationController.getStudents';
import createRegistration from '@salesforce/apex/EventRegistrationController.createRegistration';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class EventRegistration extends LightningElement {
    @track events = [];
    @track students = [];
    @track regName;
    @track selectedEventId;
    @track selectedStudentId;
    @track registrationDate;
    @track email;

    @wire(getUpcomingEvents)
    wiredEvents({ data, error }) {
        if (data) {
            this.events = data.map(evt => ({
                label: `${evt.Name} - ${evt.Date__c}`,
                value: evt.Id
            }));
        } else if (error) {
            this.showToast('Error loading events', error.body.message, 'error');
        }
    }

    @wire(getStudents)
    wiredStudents({ data, error }) {
        if (data) {
            this.students = data.map(std => ({
                label: std.Name,
                value: std.Id
            }));
        } else if (error) {
            this.showToast('Error loading students', error.body.message, 'error');
        }
    }

    handleChange(event) {
        const field = event.target.name;
        this[field] = event.target.value;
    }

    handleRegister() {
        if (!this.regName || !this.selectedStudentId || !this.selectedEventId || !this.registrationDate || !this.email) {
            this.showToast('Error', 'Please fill in all fields.', 'error');
            return;
        }

        createRegistration({
            regName: this.regName,
            studentId: this.selectedStudentId,
            eventId: this.selectedEventId,
            registrationDate: this.registrationDate,
            email: this.email
        })
            .then(result => {
                this.showToast('Success', result, 'success');
                this.regName = '';
                this.selectedStudentId = '';
                this.selectedEventId = '';
                this.registrationDate = '';
                this.email = '';
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}
