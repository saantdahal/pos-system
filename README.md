# Caféserve — Wi‑Fi Based Local Restaurant Ordering

A self-contained local ordering system for cafés and small restaurants. The admin Android device acts as the manager, server, and kitchen terminal — sharing a live menu, collecting orders, and broadcasting updates to customers' browsers over the local Wi‑Fi network. The entire system is designed to run on-premises without any external cloud dependency.

Key highlights:
- Customers join the café Wi‑Fi, scan a QR code, and interact instantly through their browser — no app install required.
- The admin device runs a local HTTP + WebSocket server and serves the user-facing web client (static HTML/JS or Flutter Web).
- Real-time order updates with local-only storage for privacy.

Table of contents
- [Overview](#overview)
- [Admin vs User — Roles and Responsibilities](#admin-vs-user---roles-and-responsibilities)
- [How It Works — Order Flow](#how-it-works---order-flow)
- [Architecture & Key Technologies](#architecture--key-technologies)
- [Recommended Packages](#recommended-packages)
- [API & Server Endpoints (examples)](#api--server-endpoints-examples)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Clone the repo](#clone-the-repo)
  - [Install dependencies](#install-dependencies)
  - [Running the Admin App (development)](#running-the-admin-app-development)
  - [Running the User Web App](#running-the-user-web-app)
- [Security & Privacy](#security--privacy)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License & Contact](#license--contact)
- [Quick Setup Checklist for Café Owners](#quick-setup-checklist-for-café-owners)

---

## Overview

Caféserve is a fully offline, on‑premises digital ordering system for cafés and small shops. The admin app (Flutter, Android) hosts the menu and an order/status dashboard, serving real‑time updates to customer devices on the same Wi‑Fi. The system emphasizes privacy and reliability by keeping all data local to the venue.

Core features:
- Local HTTP + WebSocket server running on an Android admin device.
- Full CRUD menu management (manual and Excel import).
- QR codes for Wi‑Fi onboarding and menu URL distribution.
- Real-time order and status updates via WebSockets, with polling fallback.
- Local-only storage (Hive or SQLite) — no cloud required.

---

## Admin vs User — Roles and Responsibilities

Admin App (Android)
- Manage menu: create, read, update, delete; import via Excel.
- Start/stop the local HTTP + WebSocket server and choose port.
- Generate and display QR codes:
  - Wi‑Fi QR code (SSID + password) for easy onboarding.
  - Menu URL QR code (e.g., `http://192.168.0.2:8080/menu`).
- View incoming orders and update statuses (e.g., Received → Preparing → Ready).
- Broadcast order/status updates in real time to customers.

User Web App
- Access via browser by scanning the menu QR code while on the café Wi‑Fi.
- Browse live menu and view item details.
- Place orders through a responsive order form.
- Receive real-time status updates via WebSocket (or polling fallback).

---

## How It Works — Order Flow

1. Admin configures the menu (manually or via Excel) and starts the local server.
2. Admin displays or prints the Wi‑Fi and menu QR codes.
3. Customer connects to the café Wi‑Fi and opens the menu URL from the QR code in their browser.
4. Customer adds items to their cart and submits an order.
5. Order is sent to the admin device (HTTP POST or WebSocket).
6. Admin receives the order, updates its status as it is prepared.
7. Status updates are broadcast to the customer's browser in real time.

---

## Architecture & Key Technologies

Admin app (mobile/tablet)
- Flutter for UI.
- Local server implemented in Dart (dart:io or shelf + shelf_static + shelf_web_socket).
- Local storage: Hive or SQLite.
- QR codes: qr_flutter.
- Excel import: file_picker, excel.

Server & Real-time
- shelf (HTTP server)
- shelf_static (serve web assets)
- shelf_web_socket (real‑time communication)
- WebSockets for instant order/status updates (fallback to polling if necessary).

Client (User)
- Lightweight HTML/JS/CSS web app or Flutter Web served by the admin device.
- Responsive layout for phones, tablets, and laptops.

Network
- Operates entirely on local Wi‑Fi (no internet required).

Architecture diagram (visual)
> A visual architecture diagram is ideal, but for README fallback, see the ASCII/text diagram below.
 <img width="5962" height="8937" alt="cafeserve roadmap" src="https://github.com/user-attachments/assets/1311bb06-1b68-44fe-af1c-2c5ca2bc2257" />

Text diagram :

```text
                                    ┌───────────────┐
                                    │  Café Wi‑Fi   │
                                    │  (Local LAN)  │
                                    └──────┬────────┘
                                           │
                         ┌─────────────────┴─────────────────┐
                         │           Network Switch          │
                         │        (or Wi‑Fi Access Point)    │
                         └─────────────────┬─────────────────┘
                                           │
                       ┌───────────────────┴───────────────────┐
                       │           Admin Device (Android)      │
                       │  ┌─────────────────────────────────┐  │
                       │  │ Flutter Admin App                │  │
                       │  │ - Local HTTP server (shelf)      │  │
                       │  │ - WebSocket endpoint (/ws)       │  │
                       │  │ - Menu & Orders DB (Hive/SQLite) │  │
                       │  └─────────────────────────────────┘  │
                       │           IP: 192.168.x.y:8080         │
                       └───────────────┬────────┬──────────────┘
                                       │        │
                  ┌────────────────────┘        └────────────────────┐
                  │                                             │
         ┌────────▼────────┐                           ┌────────────▼────────┐
         │ Customer Device │                           │ Customer Device     │
         │ (Phone/Laptop)  │                           │ (Phone/Tablet)      │
         │ - Browser loads │                           │ - Browser loads     │
         │   http://<admin-ip>:8080/menu            │   http://<admin-ip>:8080/menu │
         │ - Connects to /ws for real‑time updates │ - Receives broadcast updates │
         └─────────────────┘                           └──────────────────────┘
```

Notes:
- Admin binds the server to the device IP (or 0.0.0.0) and opens a chosen port (e.g., 8080).
- Customers must be on the same local Wi‑Fi subnet to reach the admin device.
- QR codes simplify onboarding by encoding Wi‑Fi credentials and the menu URL.

---

## Recommended Packages

- State Management: bloc (or provider, riverpod)
- Local Storage: hive or sqflite
- Local Server: shelf, shelf_static, shelf_web_socket
- Excel Import: file_picker, excel
- QR Code: qr_flutter
- Networking: network_info_plus
- HTTP Client: dio
- Web App: Static HTML/JS/CSS or Flutter Web
- Notifications (admin device): flutter_local_notifications
- Routing (web): go_router

---

## API & Server Endpoints (examples)

These are recommended conventions; adapt them to your implementation.

- GET /menu
  - Returns the current menu JSON (categories, items, availability, prices).
- POST /order
  - Submit a new order.
  - Payload: { orderId?, items: [{id, qty, notes}], table?, contact? }
  - Response: { orderId, acceptedAt }
- GET /order/{orderId}
  - Get current status and details for a specific order.
- GET /orders
  - Admin: list of recent/pending orders.
- POST /orders/{orderId}/status
  - Admin: update order status. Payload: { status: "Preparing" | "Ready" | ... }
- WebSocket /ws
  - Real-time channel for order events and status updates. Clients subscribe after loading the menu.

Example order JSON:
```json
{
  "orderId": "1234-5678",
  "items": [
    { "id": "espresso", "name": "Espresso", "qty": 1, "notes": "No sugar" }
  ],
  "total": 3.50,
  "table": "T4",
  "createdAt": "2025-01-10T12:45:00Z",
  "status": "Received"
}
```

Security recommendations:
- Validate and sanitize incoming payloads.
- Rate limit if needed.
- Optionally require a short-lived session token for order submission, generated by the admin for added control.

---

## Getting Started

### Prerequisites
- Flutter SDK (for the admin Android app and optional Flutter Web client)
- Dart SDK (for any standalone server code)
- An Android device to act as the admin server (phone or tablet) with Wi‑Fi capability
- Optional: a laptop/PC to develop the web frontend

### Clone the repo
```bash
git clone https://github.com/nnine-tech/sperium-lounge.git
cd sperium-lounge
```

### Install dependencies
```bash
flutter pub get
```

### Running the Admin App (development)
1. Connect your Android device via USB or use an emulator that has network bridging.
2. Run:
```bash
flutter run -d <your_device_id>
```
3. In the app:
   - Create your initial menu (or import via Excel).
   - Start the local server (choose port, e.g., 8080).
   - Display the Wi‑Fi + Menu QR codes.

For production:
```bash
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Running the User Web App
- Customers open the menu URL served by the admin device (e.g., `http://192.168.0.2:8080/menu`).
- No installation required for customers.
- For development, build a static web client and point the admin `shelf_static` handler to `build/web` or `public`.

---

## Security & Privacy

- Bind server appropriately: binding to `0.0.0.0` exposes service on all interfaces; prefer binding to the local Wi‑Fi IP if possible.
- Keep all data local: use Hive/SQLite and consider app-layer encryption for sensitive fields.
- Use input validation and rate limiting.
- Optionally issue short-lived guest tokens to prevent misuse.
- Protect admin UI behind a PIN or local authentication.

---

## Troubleshooting

- No devices can connect to the menu URL:
  - Verify the admin device IP (network_info_plus or device Wi‑Fi settings).
  - Ensure the server is bound to 0.0.0.0 or the device's IP and that the port is open.
  - Ensure clients are connected to the same Wi‑Fi network (not mobile data).
- WebSocket not connecting:
  - Confirm the WebSocket path and port are correct (e.g., ws://<admin-ip>:8080/ws).
  - Use the same scheme (ws with http) and ensure the browser's origin matches.
- Excel import failing:
  - Ensure the file is .xlsx and columns match expected mapping (name, price, category, available, imageUrl).
- Menu changes not reflected on clients:
  - Confirm the server broadcasts menu updates via WebSocket or the client polls /menu.

---

## Contributing

Contributions are welcome! Suggested workflow:
1. Fork the repository.
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Make changes and add tests where applicable.
4. Run `flutter pub get` and test the app.
5. Open a Pull Request describing the change.

Consider adding a CONTRIBUTING.md and CODE_OF_CONDUCT.md to standardize review process and behavior.

---

## License & Contact

Caféserve is a proprietary product developed and owned by Nnine Solution.
Unauthorized copying, modification, distribution, or use of this software is strictly prohibited unless explicitly permitted in writing by the owner.

All rights reserved.

Maintainer & Contact

nninesolutionteam@gmail.com

For licensing inquiries, commercial usage, partnerships, or support, please contact the maintainer directly.

---

## Quick Setup Checklist for Café Owners

1. Install Caféserve admin APK on an Android tablet/phone.
2. Connect the admin device to the café Wi‑Fi.
3. Open the admin app and add menu items (or import Excel).
4. Start the local server and display the two QR codes:
   - Wi‑Fi QR (so customers join the network quickly).
   - Menu QR (pointing to `http://<admin-ip>:<port>/menu`).
5. Customers scan the menu QR and place orders from their browser.
6. Staff manages orders from the admin app and updates statuses.
