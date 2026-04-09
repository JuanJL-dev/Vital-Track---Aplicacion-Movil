## 📱 Descripción General

**VitalTrack Mobile** es la aplicación móvil del ecosistema VitalTrack, diseñada para el monitoreo clínico en tiempo real desde dispositivos móviles. Permite a profesionales de la salud visualizar signos vitales, recibir alertas críticas y gestionar pacientes desde cualquier lugar.

> 💡 Desarrollada con Flutter, la aplicación consume servicios backend basados en Supabase, permitiendo sincronización en tiempo real, almacenamiento en la nube y escalabilidad sin servidor.

---

## ✨ Características principales

- 📡 **Monitoreo en Tiempo Real**: Visualización de signos vitales (BPM, SpO2) en vivo  
- 🚨 **Alertas Inteligentes**: Notificaciones cuando los valores exceden umbrales críticos  
- 📊 **Dashboard Móvil**: Interfaz optimizada para dispositivos móviles con métricas clave  
- 👤 **Gestión de Pacientes**: Consulta y administración de información clínica  
- 🔄 **Sincronización Cloud**: Datos actualizados en tiempo real con Supabase  
- 📱 **Multiplataforma**: Compatible con Android, Web y escalable a iOS  

---

## ⚙️ Tecnologías Utilizadas

<div align="center">
<img src="https://skillicons.dev/icons?i=flutter,dart,postgres,supabase&theme=dark" height="65"/>
</div>

<br/>

- **Flutter** → Framework multiplataforma para desarrollo móvil  
- **Dart** → Lenguaje principal de la aplicación  
- **Supabase** → Backend as a Service (BaaS), autenticación y tiempo real  
- **PostgreSQL** → Base de datos relacional en la nube  


---

## 🧠 Arquitectura del Sistema

La aplicación sigue una arquitectura cliente-servidor moderna basada en servicios en la nube. El cliente móvil desarrollado en Flutter se comunica con Supabase mediante HTTP y WebSockets para garantizar sincronización en tiempo real. Supabase gestiona la autenticación, la lógica de acceso y la persistencia en PostgreSQL, mientras que la app maneja la lógica de negocio, la visualización de datos y el almacenamiento local temporal.

---

## 📊 Módulos del Sistema

- 🔐 **Autenticación**  
  Inicio de sesión seguro y control de acceso  

- 📊 **Dashboard**  
  Visualización general de pacientes y métricas clave  

- 🫀 **Monitoreo de Signos**  
  Visualización en tiempo real de datos biométricos  

- 👥 **Pacientes**  
  Consulta y gestión de registros clínicos  

- 📈 **Estadísticas**  
  Gráficas y análisis de datos históricos  

---

## 🧩 Características Técnicas

- ✅ Arquitectura basada en widgets reutilizables  
- ✅ Consumo de APIs REST y WebSockets  
- ✅ Manejo de estado eficiente (setState / Provider / Riverpod)  
- ✅ Gráficas dinámicas para monitoreo clínico  
- ✅ Persistencia local para mejorar rendimiento  
- ✅ Sincronización en tiempo real con backend  

---

## 🚀 Ejecución del Proyecto

1. Clonar el repositorio  
   git clone https://github.com/tu_usuario/vitaltrack_app.git  

2. Entrar al proyecto  
   cd vitaltrack_app  

3. Instalar dependencias  
   flutter pub get  

4. Ejecutar en navegador  
   flutter run -d chrome  

5. Ejecutar en dispositivo o emulador  
   flutter run  

---

## 📈 Mejoras Futuras

- 🔴 Implementación de notificaciones push  
- 🟠 Integración con dispositivos IoT reales  
- 🟠 Soporte offline con sincronización automática  
- 🟡 Arquitectura limpia (Clean Architecture)  
- 🟡 Compatibilidad completa con iOS  

---

## 👥 Autor

**Universidad Tecnológica de Querétaro (UTEQ)**  
Ingeniería en Tecnologías de la Información e Innovación Digital  

- 👨‍💻 Juan Luis Cortes Matus  
- 👨‍💻 Cedric Armando Hernández García 
---

<div align="center">
VitalTrack Mobile © 2026 — Monitoreo Inteligente en Movimiento
</div>
