# Setting up GCP

1. Create the new project in the GCP console
1. Under APIs and Services -> API Library, add the following services:
    * `Google Calendar API`
    * `Google Drive API`
    * `Google People API`
1. Under APIs and Services -> [OAuth Consent Screen](https://console.cloud.google.com/apis/credentials/consent), configure as follows:
    * `User Type`: `Internal` (if allowed, otherwise `External`)
    * `Application Name`: `GSuite ACL Manager`
    * `Scopes for Google APIs`:
      * `openid`
      * `.../auth/userinfo.email`
      * `.../auth/userinfo.profile`
      * `.../auth/calendar`
      * `.../auth/calendar.acls`
      * `.../auth/calendar.calendarlist`
      * `.../auth/calendar.calendars`
      * `.../auth/docs`
      * `.../auth/drive`
      * `.../auth/drive.appdata`
      * `.../auth/drive.metadata`
      * `.../auth/contacts`
    * `Authorized Domains`: _TBD_
    * `Test Users`: Add the email of the account to be managed
1. Under APIs and Services -> [Credentials](https://console.cloud.google.com/apis/credentials), create an OAuth 2.0 Client ID:
    * `Application Type`: `Web Application`
    * `Name`: `GSuite ACL Manager`
    * `Authorized JavaScript Origins`: `http://localhost:3000`
    * `Authorized Redirect URIs`: `http://localhost:3000/auth/google/callback`
    * Save the client ID, client secret, and JSON blob ("Download JSON") somewhere safe (e.g. 1Password)
1. Under IAM and Admin -> [Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts), create a new Service Account:
    1. Create a new service account
    1. Click on the service account
    1. Under "keys", add a new key (JSON)
    1. Save the resulting file somewhere safe (e.g. in 1Password), and save a copy as `.credentials.json` in the root directory of this project
        * Make sure you have full drive encryption enabled for your computer, automatic screen locking (with a short waiting time), and a strong password on your user account
