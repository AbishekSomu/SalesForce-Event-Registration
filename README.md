 **🎯 Salesforce Event Registration Project**

📌 Overview
This is a **Salesforce Event Registration** project built using ****Apex Classes, Triggers, Lightning Web Components (LWC), and Email Templates**.  
The system allows students to register for events, sends confirmation emails automatically, and stores all related data in Salesforce.


## 📂 Project Structure

### **Apex Classes**
| File                                         |                                             Description                                                                                |
|----------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------|                          
| **EventRegistrationController.cls**          | Apex controller that handles logic for retrieving upcoming events and saving new event registrations from the Lightning Web Component. |
| **EventRegistrationController.cls-meta.xml** | Metadata configuration for the Apex controller.                                                                                        |
| **RegistrationTriggerHandler.cls**           | Trigger handler class that processes logic when a `Registration__c` record is created (e.g., validations, email sending).              |
| **RegistrationTriggerTest.cls**              | Apex test class for validating `RegistrationTriggerHandler` and controller logic in test contexts.                                     |


### **Lightning Web Component (LWC)**
| File                              |                                                         Description                                                                  |
|-----------------------------------|--------------------------------------------------------------------------------------------------------------------------------------|
| **eventRegistration.html**        | HTML template for the Event Registration LWC UI, allowing users to select a student, event, date, and email.                         |
| **eventRegistration.js**          | JavaScript file containing the LWC’s logic — retrieves data from Apex, handles form submission, and manages validations.             |
| **eventRegistration.js-meta.xml** | Metadata configuration for exposing the LWC in Lightning App Builder and making it available in the `Event Registration` custom app. |


### **Email Templates**
| File                   |                                                                 Description                                                                                                   |
|------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **email-template.txt** | Text-based Salesforce email template for sending event registration confirmations to participants. Includes merge fields for student name, event name, and registration date. |


## ⚡ Features
- **Register for Events** directly in Salesforce using LWC.
- **Automatic Email Notifications** upon successful registration.
- **Apex Trigger Support** for backend automation.
- **Dynamic Event Retrieval** from `Custom_Event__c` object.
- **Customizable Templates** for email confirmations.

---

## 🚀 Deployment
1. **Authorize Salesforce Org**

   sfdx auth:web:login -a MyDevOrg

2. **Deploy Source**

   sfdx force:source:deploy -p force-app
   Assign Permissions to users if required.

3. **Add LWC to Lightning Page**

    Open Lightning App Builder → Edit your Event Registration app page → Drag Event Registration LWC → Save and Activate.

**🧪 Testing**

Run all tests before deployment:

sfdx force:apex:test:run --resultformat human --wait 10

📷 Demo Screenshot
<img width="1918" height="907" alt="image" src="https://github.com/user-attachments/assets/1bf71918-e59c-4aae-9855-74fbbf115e02" />
<img width="1477" height="555" alt="image" src="https://github.com/user-attachments/assets/d3bfa0e7-6aab-4de9-931a-c062e6eb9f65" />


