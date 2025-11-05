# Water Quality Monitor - Arequipa

Una aplicación móvil multiplataforma desarrollada en Flutter para el monitoreo de la calidad del agua en pueblos jóvenes de Arequipa, Perú, que no tienen acceso a agua potable.

## Descripción

Esta aplicación está diseñada para monitorear la calidad del agua en pueblos jóvenes y asentamientos humanos de Arequipa mediante sensores IoT simulados. Su objetivo es proporcionar análisis en tiempo real, alertas automáticas, visualización de datos históricos y mapas de ubicación de estaciones de monitoreo para garantizar el acceso a agua segura para comunidades vulnerables.

## Arquitectura del Proyecto

El proyecto sigue los principios de **Clean Architecture** y está organizado en las siguientes capas:

```
lib/
├── core/                           # Núcleo de la aplicación
│   ├── constants/                  # Constantes globales
│   ├── errors/                     # Manejo de errores
│   ├── themes/                     # Temas y estilos
│   ├── utils/                      # Utilidades generales
│   └── widgets/                    # Widgets compartidos
├── shared/                         # Recursos compartidos
│   ├── data/                       # Servicios de datos compartidos
│   ├── domain/                     # Entidades y lógica de dominio
│   └── presentation/               # Widgets de presentación compartidos
└── features/                       # Módulos por funcionalidad
    ├── auth/                       # Autenticación de usuarios
    ├── dashboard/                  # Panel principal de monitoreo
    ├── charts/                     # Análisis y gráficos históricos
    ├── alerts/                     # Sistema de alertas
    ├── maps/                       # Localización de estaciones
    ├── settings/                   # Configuración de la app
    └── info/                       # Información y normativas
```

## Funcionalidades

### Implementadas
- **Autenticación**: Sistema de login con modo demo
- **Dashboard**: Monitoreo en tiempo real de estaciones
- **Simulación de Datos**: Generación de datos realistas de sensores
- **Modelos de Datos**: Entidades completas para agua, sensores, alertas
- **Temas**: Diseño responsive con modo claro/oscuro
- **Arquitectura**: Clean Architecture con BLoC pattern

### En Desarrollo
- **Gráficos**: Análisis histórico con charts interactivos
- **Alertas**: Sistema de notificaciones automáticas
- **Mapas**: Geolocalización de estaciones con Google Maps
- **Configuración**: Ajustes de usuario y preferencias
- **Información**: Normativas y documentación técnica

## Parámetros de Calidad del Agua

La aplicación monitorea los siguientes parámetros según normativas peruanas (DIGESA) y estándares de la OMS para agua segura:

| Parámetro | Rango Óptimo | Rango Aceptable | Unidad | Importancia para Pueblos Jóvenes |
|-----------|--------------|-----------------|---------|-----------------------------------|
| pH | 7.0 - 7.5 | 6.5 - 8.5 | pH | Esencial para salud digestiva |
| Oxígeno Disuelto | 7.0 - 10.0 | 5.0 - 14.0 | mg/L | Indica calidad biológica del agua |
| Temperatura | 18.0 - 25.0 | 0.0 - 30.0 | °C | Clima árido de Arequipa |
| Turbidez | 0.0 - 0.3 | 0.0 - 1.0 | NTU | Indicador visual de pureza |
| Conductividad | 100.0 - 300.0 | 50.0 - 500.0 | µS/cm | Minerales disueltos |
| Amoníaco | 0.0 - 0.02 | 0.0 - 0.5 | mg/L | Contaminación fecal |
| Nitritos | 0.0 - 0.1 | 0.0 - 1.0 | mg/L | Contaminación bacteriana |
| Nitratos | 0.0 - 5.0 | 0.0 - 10.0 | mg/L | Contaminación agrícola |

## Tecnologías Utilizadas

### Frontend
- **Flutter**: Framework multiplataforma
- **Dart**: Lenguaje de programación
- **BLoC**: Gestión de estado
- **Go Router**: Navegación

### UI/UX
- **Material Design 3**: Sistema de diseño
- **FL Chart**: Gráficos y visualizaciones
- **Syncfusion Charts**: Charts avanzados

### Datos y Backend (Simulado)
- **SQLite**: Base de datos local
- **CSV**: Datos de ejemplo
- **Shared Preferences**: Configuraciones

### Mapas y Localización
- **Google Maps**: Visualización de mapas
- **Geolocator**: Servicios de ubicación
- **Geocoding**: Conversión de coordenadas

### Sensores (Simulados)
- **Sensors Plus**: Simulación de sensores
- **HTTP**: Comunicación con APIs
- **WebSocket**: Datos en tiempo real

## Instalación y Configuración

### Prerrequisitos
- Flutter SDK (3.9.2 o superior)
- Dart SDK
- Android Studio / VS Code
- Git

### Instalación
```bash
# Instalar dependencias
flutter pub get

# Generar archivos de código
flutter packages pub run build_runner build

# Ejecutar la aplicación
flutter run
```

## Estaciones de Monitoreo en Pueblos Jóvenes de Arequipa

La aplicación incluye 5 estaciones de ejemplo en pueblos jóvenes de Arequipa:

1. **Alto Selva Alegre** - Zona alta sin agua potable
2. **Pueblo Joven Villa El Salvador** - Asentamiento humano 
3. **Cerro Colorado** - Zona periférica con pozos artesanales
4. **Ciudad de Dios** - Comunidad con tanques cisternas
5. **Río Seco** - Asentamiento cerca del río Chili

## Simulación de Datos

El sistema simula datos realistas con las siguientes características específicas para Arequipa:
- **70%** de lecturas en rango óptimo (ideal para consumo)
- **20%** de lecturas en rango aceptable (requiere tratamiento básico)
- **10%** de lecturas fuera de rango (peligroso para consumo - genera alertas críticas)
- Actualizaciones cada 30 segundos
- Variación según clima árido y condiciones locales
- Simulación de contaminación común en pueblos jóvenes

---
*Desarrollado con ❤️ para garantizar agua segura en los pueblos jóvenes de Arequipa, Perú*
