# Secure e-Ticket Entry Permit System (STEPS) : DC Hackathon 2023

## Problem Statement

To access the problem statement, Click [here](https://maroon-kizzee-51.tiiny.site)



## Solution and Approach


### Design

![image](https://github.com/PSYCHNERD2512/stepClient/assets/33757242/aa934a4e-d0ac-4f98-a765-b1d82f265e6a)


### Registration

- A unique ID is generated for the user account.
- Records specific events, allowed timings, and registration time.

### Main Gate Entry

- Separate QR code for Main Gate Entry.
- Tickets are not manipulated at the Main Gate.
- Re-entry allowed with the same ticket.
- Moving GIFs on QR codes to prevent screenshots and screen recording.

### Event Entry

- Each event has n gates, each with a unique QR code.
- User scans the gate's QR code, which generates another QR code.
- QR code contains Gate No/Guard No, User Info, and event details.
- Information shared among gate scanners via Bluetooth or other means.
- Validated against gate no/guard no and added to local database.

### QR Generation

- Gate/Guard Level: Encrypt UUID of gate with private key for the event.
- User Level: Keys stored on the user's phone upon signup.
- User's key used with gate's data/key for QR code generation.

### Exceptional Circumstances

- Loss of Phone: No entry for security reasons.
- App data deletion: Store event entry info in a separate file in local storage.
  - File persists after app data deletion and prevents re-entry QR generation.

#### Alternative Approach

- Allow login from multiple devices with less stringent security.
- Manage multiple entries from the same ticket and account.
- Consider attribute for the number of persons for a ticket (group booking).

## Division of Tasks

### Backend

- User login/Authentication.
- Get Events and Tickets.
- Hashes Generation.
- Check IMEI of the device and prevent login from another device.

### Frontend

- Basic flow of the app:
  - Main Gate access page.
  - Event access page.
  - Main page displaying events.
  - Profile Page.
  - Sign In page.
- Generation of encrypted file and its local storage.
- QR code generation from stored hashes.
- Permissions:
  - Storage, camera access.
  - Disallow screen sharing, screenshot permissions.
  - Device Information such as IMEI.
