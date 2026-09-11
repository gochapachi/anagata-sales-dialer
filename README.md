# Anagata Sales Dialer (Zero-VoIP Android APK)

A custom, high-speed mobile sales dialer designed for remote sales agents at **Anagata IT Solutions**. It turns ordinary Android smartphones with standard unlimited mobile SIMs (Jio / Airtel / Vi) into an enterprise call-tracking and recording terminal connected directly to **Odoo 18 CRM** via **n8n**.

---

## Key Features

1. **Daily Lead Queue Sync**: Fetches leads assigned to the sales rep directly from Odoo 18 via n8n (`GET /webhook/get-leads`).
2. **1-Tap SIM Calling**: Launches the phone's native dialer using the local SIM card (leveraging ₹299/month unlimited calling plans with **₹0 VoIP charges**).
3. **Automatic Call Duration Tracking**: Measures talk time from start to completion.
4. **Post-Call Disposition Modal**: Appears instantly when returning to the app, allowing the rep to log:
   - Call Outcome (`Interested - Build Preview`, `Connected - Pitch Delivered`, `Callback Scheduled`, `Gatekeeper Blocked`, `Not Interested`, `Wrong Number`)
   - Notes
   - Call Recording Audio file
5. **Instant Odoo Chatter & Attachment Sync**: Uploads the audio recording (MP3/M4A) and logs the call details into Odoo 18 Lead Chatter via n8n (`POST /webhook/call-log`).
6. **WhatsApp Quick-Action**: Opens prefilled WhatsApp chat with the clinic owner using Evolution API or WhatsApp Web.

---

## How to Enable Native Call Recording on Android Phones

In India and most Android regions, standard Android phones (Samsung, Xiaomi/Redmi, OnePlus, Vivo, Oppo, Realme, Tecno) have native auto-call recording built into their phone dialers:

### On Samsung Galaxy:
1. Open the native **Phone** app.
2. Tap the **3 dots** (top right) -> **Settings**.
3. Tap **Record calls** -> Turn on **Auto record calls**.
4. Recordings are saved in: `Internal Storage/Recordings/Call/`.

### On Xiaomi / Redmi / Poco:
1. Open the native **Phone / Dialer** app.
2. Tap **Settings** (gear icon) -> **Call recording**.
3. Turn on **Record calls automatically**.
4. Recordings are saved in: `Internal Storage/MIUI/sound_recorder/call_rec/`.

### On OnePlus / Oppo / Realme:
1. Open native **Phone** -> **Settings** -> **Call Recording**.
2. Enable **Record all calls**.
3. Recordings are saved in: `Internal Storage/Recordings/` or `Music/Recordings/`.

---

## How to Build the Release APK

### Prerequisites:
- Flutter SDK (v3.0.0+) installed on your workstation.
- Android SDK / Android Studio installed.

### Build Steps:
```bash
cd android_dialer

# 1. Fetch dependencies
flutter pub get

# 2. Build Release APK
flutter build apk --release --split-per-abi

# The generated APK will be located at:
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

Distribute this APK file to your remote sales agents via Google Drive, WhatsApp, or Telegram.

---

## App Configuration

When the app opens for the first time:
1. Tap the **Settings** icon (top right).
2. Enter your n8n Webhook URL: `https://n8n.anagataitsolutions.in/webhook`
3. Enter the Sales Rep Name: e.g. `Rahul Sharma`
4. Tap **Save**.
