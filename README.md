# FuelIQ — Smart Fuel Consumption Tracker

A modern Android app built with Flutter for tracking vehicle fuel consumption, monitoring gauge levels, and calculating fuel efficiency.

---

## Features

- **Animated Fuel Gauge** — Visual arc gauge matching your physical dashboard (E to F with color-coded levels)
- **Multi-Vehicle Support** — Track Cars, Motorcycles, Trucks, Vans, SUVs, Buses, and Tuk-tuks
- **Fuel Consumption Calculation** — Automatic km/L calculation between log entries
- **Estimated Range** — Real-time remaining range based on average efficiency
- **Consumption Trend Chart** — Line chart of fuel efficiency over time
- **Full History** — Every entry with trip stats, swipe-to-delete
- **Offline / Local** — All data stored on-device via SQLite (no internet required)
- **Dark Theme** — Modern dark UI with cyan accent

---

## Screenshots

> _Add screenshots here_

---

## How It Works

### Logging an Entry
Each log entry captures:
| Field | Description |
|---|---|
| Date | When the reading was taken |
| Odometer (km) | Current dashboard km reading |
| Gauge poles | How many indicator segments are lit on the physical gauge |
| Liters filled | Optionally, how many liters you put in (when refueling) |

### Fuel Consumption Formula

```
fuelRemaining  = (currentPoles / totalPoles) × tankCapacity
fuelConsumed   = prevFuelRemaining + litersFilled − currFuelRemaining
consumption    = kmRun / fuelConsumed         (km/L)
estimatedRange = fuelRemaining × avgConsumption
```

### Gauge Setup
When adding a vehicle, set **total gauge poles** to match your physical fuel gauge:
- Most cars: **8 poles** (each = 1/8 tank)
- Motorcycles: **4 poles**
- Some vehicles: 6, 10, or 16 poles

---

## Getting Started

### Prerequisites
- Flutter SDK `^3.7.x`
- Android Studio or VS Code with Flutter plugin
- Android device or emulator (API 21+)

### Install & Run

```bash
git clone <repo-url>
cd fuel_cal
flutter pub get
flutter run
```

### Build Release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## Custom App Icon

1. Prepare your icon as a **1024×1024 PNG** with transparent or solid background
2. Place it at:
   ```
   assets/icon/app_icon.png
   ```
3. Run the icon generator:
   ```bash
   dart run flutter_launcher_icons
   ```
4. Rebuild the app:
   ```bash
   flutter run
   ```

> **Tip for adaptive icons:** The icon is used as both the standard and adaptive foreground layer. For best results on Android 8+, use a design with safe zone padding (the central ~66% of the image).

---

## Project Structure

```
lib/
├── main.dart                  # Entry point
├── app.dart                   # App root + provider wiring
├── theme.dart                 # Dark theme definition
├── database_helper.dart       # SQLite singleton (sqflite)
├── models/
│   ├── vehicle.dart
│   ├── fuel_entry.dart
│   └── trip_stat.dart         # Computed consumption between entries
├── providers/
│   ├── vehicle_provider.dart
│   └── fuel_entry_provider.dart
├── screens/
│   ├── app_shell.dart         # Bottom navigation shell
│   ├── dashboard_screen.dart  # Main dashboard
│   ├── log_entry_screen.dart  # Add fuel entry form
│   ├── history_screen.dart    # Entry history list
│   ├── vehicles_screen.dart   # Vehicle management
│   └── add_vehicle_screen.dart
└── widgets/
    ├── fuel_gauge_widget.dart  # Animated arc gauge (CustomPainter)
    ├── gauge_poles_stepper.dart
    ├── stat_card.dart
    └── consumption_chart.dart  # fl_chart line chart
```

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| `sqflite` | ^2.3.3 | Local SQLite database |
| `path` | ^1.9.0 | DB file path resolution |
| `provider` | ^6.1.2 | State management |
| `intl` | ^0.20.1 | Date formatting |
| `fl_chart` | ^0.70.0 | Consumption trend chart |
| `flutter_launcher_icons` | ^0.14.1 | App icon generation (dev) |

---

## Color Palette

| Name | Hex | Usage |
|---|---|---|
| Primary (Cyan) | `#00C8FF` | Accent, buttons, selected |
| Background | `#0A0E1A` | Screen backgrounds |
| Surface | `#141828` | Bottom nav, sheets |
| Card | `#1C2440` | Cards, inputs |
| Success (Green) | `#00E676` | Full tank, good efficiency |
| Warning (Yellow) | `#FFD600` | Medium level |
| Danger (Red) | `#FF1744` | Critical fuel level |

---

## License

MIT
