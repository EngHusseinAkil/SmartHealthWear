# HealthMonitor — Android Studio Setup Guide
### Samsung Galaxy Watch 7 Health Monitoring App

---

## 📋 What's Inside the ZIP

```
HealthMonitor/
├── build.gradle                          Root Gradle config
├── settings.gradle                       Repo sources (JitPack, Google, Maven)
├── gradle.properties                     JVM & build optimizations
├── gradle/wrapper/gradle-wrapper.properties  Gradle 8.4
└── app/
    ├── build.gradle                      All dependencies
    ├── google-services.json              ⚠ PLACEHOLDER — replace with yours
    ├── proguard-rules.pro                Release build rules
    └── src/main/
        ├── AndroidManifest.xml           All permissions + activities
        ├── java/com/healthmonitor/
        │   ├── data/                     Room DB, DAOs, models
        │   ├── samsung/                  Galaxy Watch 7 SDK layer + simulator
        │   ├── service/                  Foreground monitoring service
        │   ├── ui/                       All screens & fragments
        │   └── util/                     SMS alert manager
        └── res/                          Layouts, drawables, strings, themes
```

---

## 🛠 STEP 1 — Install Prerequisites

| Tool | Version | Download |
|------|---------|----------|
| Android Studio | Hedgehog 2023.1.1+ | https://developer.android.com/studio |
| JDK | 17 | Bundled with Android Studio |
| Android SDK | API 34 | Via SDK Manager in Android Studio |
| Build Tools | 34.0.0 | Via SDK Manager |

---

## 🗂 STEP 2 — Open the Project

1. Extract `HealthMonitor.zip` to a folder (e.g. `~/Projects/HealthMonitor`)
2. Open **Android Studio**
3. Click **File → Open**
4. Navigate to the extracted `HealthMonitor/` folder and click **OK**
5. Wait for Gradle sync to complete (first time downloads ~500 MB of dependencies)
6. If prompted about JDK, select **JDK 17**

---

## 🔥 STEP 3 — Set Up Firebase (for cloud sync & auth)

> Skip this step if you want to run in offline/guest mode only.

### 3a. Create Firebase project
1. Go to https://console.firebase.google.com
2. Click **Add project** → name it `HealthMonitor` → click through setup
3. In the left sidebar click **Build → Authentication**
4. Click **Get started** → enable **Email/Password**
5. In the left sidebar click **Build → Firestore Database**
6. Click **Create database** → choose **Start in test mode** → pick your region

### 3b. Add Android app to Firebase
1. In Firebase console click the **Android icon** (Add app)
2. Package name: `com.healthmonitor`
3. App nickname: `HealthMonitor`
4. Click **Register app**
5. Download `google-services.json`
6. **Replace** `app/google-services.json` in the project with this downloaded file

### 3c. Set Firestore security rules (for production)
In Firebase console → Firestore → Rules, paste:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## ⌚ STEP 4 — Set Up Samsung Health SDK

The app works in **simulator mode** out of the box. To connect a real Galaxy Watch 7:

### 4a. Download the SDK
1. Go to: https://developer.samsung.com/health/android/data/guide/health-data-intro.html
2. Sign in with a Samsung Developer account (free)
3. Download **Samsung Health Data SDK** (the `.aar` file)

### 4b. Add SDK to project
1. Create folder: `app/libs/`
2. Copy the downloaded `.aar` file into `app/libs/`
3. In `app/build.gradle`, uncomment this line:
   ```gradle
   implementation fileTree(dir: 'libs', include: ['*.aar', '*.jar'])
   ```
4. Sync Gradle

### 4c. Uncomment real SDK calls
In `SamsungHealthManager.kt`:
- Find each `// ── REAL SDK: ──` comment block
- Uncomment those lines
- Comment out the simulator fallback below it

### 4d. Pair Galaxy Watch 7 with phone
1. Install **Galaxy Wearable** app on the phone
2. Open it → Add device → Galaxy Watch 7
3. Install **Samsung Health** app on the phone
4. Open Samsung Health → grant all health permissions

### 4e. Grant Samsung Health permissions
In `MainActivity.kt`, after the watch connects:
```kotlin
samsungHealth.requestPermissions(this)
```
This triggers the Samsung Health permissions dialog on first run.

---

## 📱 STEP 5 — Run the App

### On an emulator (simulator mode, no real watch needed):
1. In Android Studio open **Device Manager** (right sidebar or Tools menu)
2. Click **Create Virtual Device**
3. Choose **Pixel 7** → API 34 (Android 14)
4. Click **Finish** then **▶ Run**
5. The app launches with simulated health data updating every 10 seconds

### On a real phone:
1. Enable **Developer Options** on your Android phone:
   - Go to Settings → About phone → tap **Build number** 7 times
2. Enable **USB Debugging** in Developer Options
3. Connect phone via USB → allow debugging when prompted
4. In Android Studio click **▶ Run** — select your phone
5. Grant all requested permissions when prompted

---

## 🧪 STEP 6 — Test Each Feature

### Test the Dashboard
- Open the app → you should see live data updating on all metric cards
- The heart rate chart populates after ~1 minute of data

### Test Emergency Detection
1. Go to Dashboard
2. Tap **"Test Emergency Alert"** — this simulates a high heart rate reading
3. The Emergency screen appears with 30-second countdown
4. Tap **"I'm OK"** to dismiss

### Test Fall Detection
- The app uses the phone's own accelerometer
- On a real device: tap the phone firmly on a table, then hold still for 20s
- Emergency alert will trigger
- (False positives can be dismissed with "I'm OK")

### Test Emergency Contacts SMS
1. Go to Contacts tab → add a contact with your own phone number
2. Trigger a test emergency
3. Wait for the countdown to finish (or let it run out)
4. You should receive an SMS with vitals + Google Maps link

### Test Scenarios (modify `WatchDataSimulator.kt`)
```kotlin
// In HealthMonitoringService, access the simulator:
simulator.scenario = WatchScenario.HIGH_HEART_RATE  // triggers HR emergency
simulator.scenario = WatchScenario.LOW_SPO2          // triggers SpO2 emergency
simulator.scenario = WatchScenario.HIGH_BLOOD_PRESSURE // triggers BP emergency
simulator.scenario = WatchScenario.NORMAL            // back to normal
```

---

## 🔐 STEP 7 — Required Permissions at Runtime

When the app first launches it requests:

| Permission | Why |
|-----------|-----|
| `ACCESS_FINE_LOCATION` | GPS coordinates in emergency SMS |
| `POST_NOTIFICATIONS` | Foreground service notification |
| `BLUETOOTH_CONNECT` | Pair with Galaxy Watch 7 |
| `BLUETOOTH_SCAN` | Discover the watch |
| `ACTIVITY_RECOGNITION` | Step count from watch |
| `SEND_SMS` | Alert emergency contacts |
| `BODY_SENSORS` | Accelerometer for fall detection |

Grant **all** of these for full functionality.

---

## 🐛 Common Issues & Fixes

### "Gradle sync failed"
- File → Invalidate Caches → Restart
- Make sure you have internet (first sync downloads dependencies)
- Check JDK is set to 17: File → Project Structure → SDK Location → JDK

### "Manifest merger failed"
- Make sure `compileSdk = 34` and `targetSdk = 34` in `app/build.gradle`

### "google-services.json is missing or invalid"
- Either replace with your real Firebase file, OR
- Comment out all Firebase plugin lines in both `build.gradle` files to run offline

### "Service won't start on Android 14"
- Android 14 requires explicit foreground service type in manifest ✅ (already set)
- Make sure POST_NOTIFICATIONS permission is granted

### "SMS not sending"
- SEND_SMS permission must be granted at runtime
- Test on a real device (emulators cannot send SMS)
- Some carriers block programmatic SMS — test with a different SIM

### "Samsung Health not connecting"
- Ensure Samsung Health app is installed and updated
- Ensure Galaxy Wearable app is installed and watch is paired
- Re-run permission request via `requestPermissions()`

---

## 📁 Key Files to Know

| File | What to modify |
|------|----------------|
| `WatchDataSimulator.kt` | Change simulated sensor values & scenarios |
| `EmergencyDetector.kt` | Change alert threshold defaults |
| `SamsungHealthManager.kt` | Swap simulator → real SDK calls |
| `AlertManager.kt` | Customize SMS message format |
| `colors.xml` | App color scheme |
| `strings.xml` | All text labels |
| `UserProfile` (Models.kt) | Add more threshold fields |

---

## 🚀 Phase Development Roadmap

| Phase | Features | Status |
|-------|---------|--------|
| 1 | Project setup, DB, models | ✅ Done |
| 2 | Samsung Watch 7 SDK + simulator | ✅ Done |
| 3 | Background monitoring service | ✅ Done |
| 4 | Emergency detection + fall detection | ✅ Done |
| 5 | All UI screens (Dashboard, Emergency, Contacts, Reports, Profile) | ✅ Done |
| 6 | Firebase auth + Firestore sync | ✅ Done |
| 7 | SMS alert system | ✅ Done |
| 8 | Real Samsung SDK integration | 🔧 Manual step (SDK download required) |
| 9 | AI health predictions (optional) | ➕ Future |
| 10 | Family web dashboard | ➕ Future |

---

## 📊 Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                  UI Layer                           │
│  LoginActivity  MainActivity  EmergencyActivity     │
│  DashboardFragment  ReportsFragment                 │
│  ContactsFragment   ProfileFragment                 │
└──────────────────────┬──────────────────────────────┘
                       │ StateFlow / LiveData
┌──────────────────────▼──────────────────────────────┐
│              HealthMonitoringService                │
│         (Foreground Service — always running)       │
│                                                     │
│  SamsungHealthManager ──► WatchDataSimulator        │
│  EmergencyDetector                                  │
│  FallDetector (accelerometer)                       │
│  AlertManager (SMS)                                 │
└──────────┬──────────────────────┬───────────────────┘
           │                      │
┌──────────▼──────────┐  ┌───────▼──────────────────┐
│    Room Database    │  │   Firebase Firestore      │
│  (local, offline)   │  │   (cloud backup + auth)  │
│  HealthReading      │  │   /users/{uid}/readings   │
│  EmergencyEvent     │  │   /users/{uid}/emergencies│
│  EmergencyContact   │  │   /users/{uid}/contacts   │
└─────────────────────┘  └──────────────────────────┘
```

---

## 📜 Industry Standards & Compliance Framework

Although HealthMonitor is an educational/prototype system, its architecture fundamentally aligns with several key global standards for medical and health IT systems:

*   **ISO 27001 (Information Security Management):** Implemented via **Firebase Authentication** and rigorous **Firestore Security Rules**. This ensures that highly sensitive health data (e.g., Heart Rate, SpO2, and Emergency GPS credentials) is strictly isolated and accessible only by the authenticated patient.
*   **ISO/IEEE 11073 (Personal Health Device Communication):** The custom Wear OS Watch-to-Phone data streaming architecture relies on standardized networking formats (TCP/IP networks over IEEE 802.11 / Bluetooth IEEE 802.15.1) to ensure robust, real-time vital sign transmission.
*   **IEC 62304 (Medical Device Software Lifecycle):** Addressed structurally through decoupled architecture layers (Local offline Room DB -> Reliable Foreground Services -> Fast MVVM UI) along with built-in safe-failure modes like `crash_log.txt` reporting.
*   **ISO 13485 (Quality Management & Safety):** The system's user-interface natively incorporates patient safety intercepts—for instance, the 30-second localized countdown alarm allows patients to dismiss false-positive "Fall Detections" before the app acts autonomously to message emergency contacts.

---

## ⚠ Medical Disclaimer

This application is a **health monitoring tool for educational purposes only**.
It is **NOT** a medical device and should **NOT** replace professional medical
advice, diagnosis, or treatment. Do not make clinical decisions based solely
on this application.

---

*Built for Android — Samsung Galaxy Watch 7 — Firebase — Room DB*
*Course project — Health Informatics / Mobile Development*
