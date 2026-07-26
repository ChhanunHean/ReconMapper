# ReconMapper

ReconMapper is an offensive security utility designed to simulate and automate the reconnaissance phase of ethical hacking. Built as a course project for CADT IDT - Mobile App Development (Year 2 Term 3), this app provides real-time information gathering, automated vulnerability scans, risk analysis, and continuous monitoring of target exposures.

The team behind this project consists of Hean Chhanun and Roeurn Sokviseth.

---

## Key Features

* **Multi-Vector Scanning:** Automated target analysis across five security vectors:
  * **DNS Lookup:** Resolves domains to active IP addresses.
  * **Ping Latency:** Tracks round-trip latency (ping_ms) for target reachability.
  * **Port Scan:** Scans common and dangerous network ports (FTP, SSH, MySQL, RDP, HTTP-alt).
  * **SSL/TLS Inspector:** Validates SSL configurations, details certificate authority issuers, and tracks expiry countdowns.
  * **Security Headers Analyst:** Grades site safety based on the presence of security headers (HSTS, CSP, X-Frame-Options, etc.).
* **Geo-IP Geolocation:** Dynamically locates target servers (City, Country) using a lightweight geolocation scanner API.
* **Firewall and Tech Stack Detection:** Identifies active Web Application Firewalls (WAF) such as Cloudflare, AWS CloudFront, Sucuri, and exposes the backend technology stacks (PHP, Java, Python, Laravel).
* **Continuous Background Auto-Scanning:** An active python daemon scheduler queries the local SQLite database and re-scans every target automatically every 60 seconds.
* **Live UI Countdown Timer:** The Flutter dashboard displays a live countdown timer counting down from 60s to 0s and performs silent API refreshes upon expiry to reflect risk updates.
* **Dynamic Risk Engine:** Calculates a 0-100 exposure risk score and classes targets into Low, Medium, High, or Critical risk levels.
* **Report Exports:** Serializes complete scan intelligence packages into clean JSON files that can be shared natively from the phone.
* **Full CRUD Lifecycle:** Add domains dynamically, monitor them in real-time, inspect granular findings, and securely delete records from your monitoring list with safety confirmation dialogs.

---

## Architecture and Data Flow

ReconMapper is split into two components to bypass mobile sandbox restrictions (which block raw ICMP pings and direct low-level socket operations):

1. **recon_mapper (Flutter Mobile App):** The user interface client responsible for gathering input, presenting target cards, displaying status/risk levels, and outputting JSON reports.
2. **reconmapper-api (FastAPI Backend + SQLite):** A local web server and background daemon that executes the active scanners, calculates risk, schedules periodic scans, and stores targets in a local reconmapper.db SQLite database file.

```
                  +--------------------------------+
                  |  Flutter Mobile client (App)   |
                  +---------------+----------------+
                                  |
                   HTTP GET/POST  |  JSON payload
                                  v
                  +---------------+----------------+
                  |     FastAPI Backend (API)      |
                  +---------------+----------------+
                                  |
                   SQLAlchemy     |  Background Thread Loop
                                  v  (Runs Scans every 60s)
                  +---------------+----------------+
                  |     SQLite Database (.db)      |
                  +--------------------------------+
```

---

## Tech Stack

* **Mobile App:** Flutter and Dart.
* **API Service:** FastAPI (Python 3.13) and SQLAlchemy ORM.
* **Database:** SQLite (local file database).
* **Styling:** Premium dark mode matching a red/black offensive security aesthetic.

---

## Getting Started

### 1. Prerequisites
Ensure you have the following installed on your developer machine:
* Flutter SDK
* Python 3.13+
* An active Android or iOS emulator

---

### 2. Backend Setup (reconmapper-api)

Navigate to the backend directory:
```bash
cd reconmapper-api
```

#### Set up Virtual Environment
Create and activate a Python virtual environment to manage dependencies locally:
* **macOS / Linux:**
  ```bash
  python3 -m venv .venv
  source .venv/bin/activate
  ```
* **Windows:**
  ```cmd
  python -m venv .venv
  .venv\Scripts\activate
  ```

#### Install Dependencies
```bash
pip install -r requirements.txt
```

#### Run the Server
Launch the FastAPI server with hot-reload enabled:
```bash
uvicorn app.main:app --reload
```
Upon startup, the console will output:
```
[Scheduler] Background auto-scanner thread starting...
INFO:     Application startup complete.
```
The API is now running locally on http://127.0.0.1:8000.

---

### 3. Mobile App Setup (recon_mapper)

Navigate to the Flutter project folder:
```bash
cd ../recon_mapper
```

#### Fetch Packages
```bash
flutter pub get
```

#### Verify Emulators
Check that Flutter successfully sees your running virtual device:
```bash
flutter devices
```

#### Run the App
```bash
flutter run
```
*(The Flutter client is configured to automatically route backend requests to http://10.0.2.2:8000 on Android Emulators and http://127.0.0.1:8000 on iOS Simulator/Mac Desktop.)*

---

### 4. Mobile Distribution and Cross-Platform Web Demo

The primary deliverable of this project is the native Android application. To build the final installation package (APK) for mobile devices, navigate to the `recon_mapper` folder and run:
```bash
flutter build apk --release
```
The output installer will be generated at `build/app/outputs/flutter-apk/app-release.apk`.

To demonstrate the cross-platform capabilities of the Flutter codebase and provide an instant, interactive browser preview of the mobile user interface for grading convenience, you can deploy a web demo of the application to a public domain:

#### Cross-Platform Web Demo Deployment (Cloudflare Pages)
1. **Compile Web Assets:**
   In the `recon_mapper` directory, build the release web package:
   ```bash
   flutter build web --release
   ```
2. **Deploy Web Folder:**
   * Go to **Cloudflare Dashboard** -> **Workers & Pages** -> **Create Application** -> **Pages** tab -> **Upload your static files** (Direct Upload).
   * Project name: `reconmapper`.
   * Drag and drop the `build/web` folder from your Mac.
   * Click **Deploy**.
3. **Link Custom Domain:**
   * Under the deployed project, select the **Custom Domains** tab.
   * Add `chhanun.site` as your custom domain. *(Ensure you delete any conflicting root A records in your Cloudflare DNS table first).*


#### Backend API Tunneling (Cloudflare Tunnel)
1. **Authenticate Cloudflared CLI:**
   Run the login command and authorize `chhanun.site` in your browser:
   ```bash
   cloudflared tunnel login
   ```
2. **Create the Tunnel:**
   Create a named tunnel:
   ```bash
   cloudflared tunnel create reconmapper
   ```
3. **Route Subdomain to Tunnel:**
   Bind a subdomain (e.g., `api.chhanun.site`) to the tunnel:
   ```bash
   cloudflared tunnel route dns reconmapper api.chhanun.site
   ```
4. **Run the Tunnel:**
   Forward traffic from the public subdomain directly to your local FastAPI backend (running on port 8000):
   ```bash
   cloudflared tunnel run --url http://localhost:8000 reconmapper
   ```

#### Code Configuration
In `lib/services/api_service.dart`, set the `useTunnel` boolean flag to `true` to route API requests to your secure custom domain:
```dart
class ApiService {
  static const bool useTunnel = true; // Set to true to use Cloudflare Tunnel
  ...
}
```

---

## Project Structure

```
ReconMapper/
├── recon_mapper/               # Flutter mobile application
│   ├── lib/
│   │   ├── models/             # Dart models (scan_result.dart)
│   │   ├── screens/            # UI Screens (dashboard, add_target, target_detail)
│   │   ├── services/           # HTTP API client (api_service.dart)
│   │   ├── theme/              # Red/Black color styling (app_theme.dart)
│   │   ├── widgets/            # Custom reusable widgets (target_card, risk_badge, loading_spinner)
│   │   └── main.dart           # App entry point
│   └── pubspec.yaml
│
└── reconmapper-api/            # FastAPI Python backend
    ├── app/
    │   ├── routers/            # API endpoints (scan.py)
    │   ├── scanners/           # Scanner modules (dns_lookup.py, ping.py, port_scan.py, ssl_check.py, header_analysis.py, location.py)
    │   ├── database.py         # SQLAlchemy configuration
    │   ├── models.py           # SQLite database schemas
    │   ├── schemas.py          # Pydantic validation schemas
    │   ├── risk_engine.py      # Numerical risk calculation algorithms
    │   ├── scheduler.py        # Background periodic auto-scanner loop
    │   └── main.py             # FastAPI entry point & startup handlers
    ├── requirements.txt
    └── reconmapper.db          # Local SQLite file (Git-ignored)
```

---

## License
This project is built purely for academic purposes under the CADT Mobile Application Development curriculum. Unauthorized distribution or malicious use of scanning modules is strictly discouraged.
