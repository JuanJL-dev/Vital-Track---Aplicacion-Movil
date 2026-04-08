# VitalTrack 🩺

A comprehensive mobile application built with Flutter for monitoring and analyzing patient health metrics in real-time. VitalTrack simulates IoT hardware integration to track vital signs and synchronizes data seamlessly with a Supabase (PostgreSQL) backend.

## 🚀 Key Features

* **Real-Time Vitals Tracking:** Monitors Heart Rate, Blood Pressure, SpO2, Sleep cycles, and Daily Steps.
* **Algorithmic Data Simulation:** Implements a "Random Walk" algorithm to generate organic, medically consistent mock IoT data for seamless testing without physical hardware.
* **Cloud Synchronization:** Deep integration with Supabase for robust PostgreSQL data persistence.
* **Role-Based Data Access:** Strict separation of concerns where patients can only edit basic profile information, while clinical thresholds and historical records remain immutable and secure.
* **Responsive UI:** Adaptive grid layouts and responsive cards using `fl_chart` for historical data visualization.

## 🛠 Tech Stack

* **Frontend:** Flutter & Dart
* **State Management:** Provider
* **Backend as a Service (BaaS):** Supabase (Authentication, PostgreSQL Database)
* **Architecture:** Clean Architecture principles (Core, Data, Presentation layers)

## 📁 Project Architecture

The project follows a structured modular approach to ensure scalability and maintainability:

```text
lib/
 ┣ core/          # Theme, constants, and utilities (e.g., Random Walk generator)
 ┣ data/          # Models, Repositories, and External Services (Supabase, Mock IoT)
 ┣ presentation/  # UI components, Screens, and State Providers
 ┗ main.dart      # Application entry point and Provider initialization

⚙️ Local Development Setup
Clone the repository:


git clone [https://github.com/CedrikHG/vitaltrack.git](https://github.com/CedrikHG/vitaltrack.git)
Install dependencies:


flutter pub get
Set up Supabase:

Ensure your lib/core/constants/supabase_constants.dart file is populated with your project URL and Anon Key.

Run the application:

flutter run
📈 Future Roadmap
Physical IoT Bluetooth Low Energy (BLE) integration.

Advanced analytics dashboard for medical professionals (Web Client).

Push notifications for abnormal vital sign alerts.


### 2. Estrategia de Commits (Subir los cambios)
Para que tu historial de GitHub se vea limpio y organizado, vamos a subir todo lo que arreglamos hoy usando el estándar de la industria. 

Abre tu terminal en VS Code y ejecuta estos comandos uno por uno:

git add .


git commit -m "refactor(vitals): implement strict data typing for Supabase synchronization" -m "Fixed silent crash by ensuring data types (int/double) match the PostgreSQL schema. Refactored VitalsProvider to enforce integer parsing before payload dispatch."


git commit -m "fix(ui): resolve RenderFlex overflow on vital cards" -m "Adjusted GridView childAspectRatio to 0.75 and implemented FittedBox to ensure dynamic text scaling on smaller physical devices."


git push