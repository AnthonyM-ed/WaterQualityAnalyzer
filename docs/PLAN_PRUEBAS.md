# Plan de Pruebas - Sistema de Monitoreo de Calidad del Agua

## Objetivo General
Validar que el sistema cumple con los requisitos de funcionalidad, rendimiento, usabilidad y accesibilidad para garantizar una gestión eficiente de datos y monitorización en tiempo real.

---

## 1. Pruebas de Mejora en Gestión de Datos y Monitorización

### 1.1 Pruebas de Tiempo Real y Actualización de Datos

#### PT-001: Latencia de Actualización de Sensores
**Objetivo**: Verificar que las lecturas se actualicen cada 30 segundos  
**Tipo**: Funcional + Rendimiento

**Procedimiento**:
1. Iniciar la aplicación en modo tiempo real
2. Observar el dashboard con las 3 estaciones
3. Cronometrar el tiempo entre actualizaciones consecutivas
4. Registrar 10 ciclos de actualización

**Criterios de Éxito**:
- Intervalo entre lecturas: 30s ± 2s
- No se pierden actualizaciones durante 10 minutos
- UI responde en <200ms tras recibir datos

**Métricas**:
```
Tiempo promedio entre lecturas: _____ segundos
Actualizaciones exitosas: _____ / 20
Tiempo de renderizado UI: _____ ms
```

---

#### PT-002: Sincronización Firebase en Tiempo Real
**Objetivo**: Validar que los datos se guardan inmediatamente en Firebase  
**Tipo**: Integración

**Procedimiento**:
1. Abrir Firebase Console en navegador
2. Ejecutar app en dispositivo con conexión WiFi
3. Observar dashboard y consola Firebase simultáneamente
4. Verificar que cada lectura aparece en Firebase al momento

**Criterios de Éxito**:
- Datos visibles en Firebase <3s después de generarse
- Estructura correcta: `readings/{stationId}/{timestamp}`
- Campo `latest` se actualiza correctamente

**Métricas**:
```
Latencia de sincronización promedio: _____ ms
Lecturas perdidas: _____ / 50
Consistencia de estructura: _____ %
```

---

#### PT-003: Persistencia Offline y Resincronización
**Objetivo**: Verificar que el modo offline funciona correctamente  
**Tipo**: Integración + Resiliencia

**Procedimiento**:
1. Iniciar app con conexión activa
2. Esperar 2 minutos (4 lecturas generadas)
3. Desactivar WiFi y datos móviles
4. Esperar 3 minutos más (6 lecturas en caché)
5. Reactivar conexión
6. Verificar en Firebase que las 6 lecturas se sincronizaron

**Criterios de Éxito**:
- App funciona sin errores en modo offline
- Caché almacena al menos 100 lecturas
- Al reconectar, todas las lecturas se sincronizan en <30s
- No hay duplicados en Firebase

**Métricas**:
```
Lecturas almacenadas offline: _____ / 6
Tiempo de resincronización: _____ segundos
Lecturas duplicadas: _____ (debe ser 0)
Errores reportados: _____ (debe ser 0)
```

---

### 1.2 Pruebas de Optimización de Recursos

#### PT-004: Consumo de Memoria
**Objetivo**: Validar que la app no consume memoria excesiva  
**Tipo**: Rendimiento

**Procedimiento**:
1. Abrir Android Studio Profiler (o equivalente)
2. Ejecutar app en modo Release
3. Dejar funcionando 30 minutos en modo tiempo real
4. Alternar entre pantallas (Dashboard, Gráficos)
5. Cargar gráfico de 90 días (máximo volumen de datos)
6. Registrar memoria promedio y picos

**Criterios de Éxito**:
- Memoria promedio: <150MB
- Sin memory leaks (gráfico estable)
- Picos transitorios <200MB
- GC (Garbage Collection) no causa lag perceptible

**Métricas**:
```
Memoria promedio: _____ MB
Memoria máxima: _____ MB
Incremento de memoria en 30 min: _____ MB
Frecuencia de GC: _____ veces/minuto
```

---

#### PT-005: Rendimiento de Gráficos con Datasets Grandes
**Objetivo**: Verificar que los gráficos mantienen fluidez con muchos datos  
**Tipo**: Rendimiento

**Procedimiento**:
1. Cargar gráfico de 90 días (máximo datos históricos)
2. Medir frames por segundo (FPS) durante scroll
3. Cambiar entre diferentes métricas (pH, TDS, Turbidez)
4. Alternar entre estaciones
5. Usar herramienta Flutter DevTools > Performance

**Criterios de Éxito**:
- FPS: ≥55 (en pantalla 60Hz)
- Tiempo de carga de gráfico: <2s
- Sin frames perdidos durante scroll
- Muestreo inteligente activo (máximo 50 puntos para 24h)

**Métricas**:
```
FPS promedio: _____ fps
Tiempo de carga 90d: _____ ms
Frames perdidos: _____ (debe ser 0)
Puntos renderizados (24h): _____ (máximo 50)
```

---

#### PT-006: Eficiencia de Consultas Firebase
**Objetivo**: Medir la eficiencia de las consultas a Firebase  
**Tipo**: Rendimiento + Costos

**Procedimiento**:
1. Abrir Firebase Console > Database > Usage
2. Cargar gráficos históricos para las 3 estaciones
3. Anotar cantidad de lecturas descargadas
4. Verificar que no se descargan datos innecesarios
5. Revisar logs de consultas en Flutter

**Criterios de Éxito**:
- Consulta 24h: <100 lecturas por estación
- Consulta 90d: Solo datos del rango solicitado
- Sin consultas duplicadas en <5 minutos
- Filtrado en memoria (no múltiples queries)

**Métricas**:
```
Lecturas descargadas (24h): _____ / estación
Lecturas descargadas (90d): _____ / estación
Consultas Firebase en 5 min: _____ 
Datos filtrados en cliente: _____ %
```

---

### 1.3 Pruebas de Precisión de Datos

#### PT-007: Validación de Umbrales de Calidad
**Objetivo**: Verificar que los indicadores de calidad son correctos  
**Tipo**: Funcional

**Procedimiento**:
1. Revisar datos históricos en Firebase
2. Seleccionar 10 lecturas aleatorias
3. Calcular manualmente el estado (verde/amarillo/rojo)
4. Comparar con la UI de la app

**Valores de Referencia**:
```
pH: 6.5-8.5 (verde), fuera de rango (rojo)
TDS: <200 (verde), 200-300 (amarillo), >300 (rojo)
Turbidez: <3 (verde), 3-5 (amarillo), >5 (rojo)
Temperatura: 15-30°C (verde), fuera de rango (amarillo)
```

**Criterios de Éxito**:
- 100% de coincidencia entre cálculo manual y UI
- Cambios de estado reflejan inmediatamente en UI
- Iconos de estado correctos (✓ / ⚠ / ✗)

**Métricas**:
```
Coincidencias: _____ / 10
Tiempo de actualización visual: _____ ms
Errores de clasificación: _____ (debe ser 0)
```

---

#### PT-008: Integridad de Datos CSV vs Firebase
**Objetivo**: Validar que la migración CSV → Firebase fue correcta  
**Tipo**: Integridad de Datos

**Procedimiento**:
1. Ejecutar script `migrate_csv_to_firebase.dart`
2. Contar lecturas en archivo CSV original
3. Consultar Firebase y contar lecturas migradas
4. Comparar 5 lecturas aleatorias (valores exactos)

**Criterios de Éxito**:
- Cantidad de lecturas: CSV = Firebase
- Valores coinciden al 100% (pH, TDS, turbidez, temp)
- Timestamps ajustados correctamente a 2025
- Sin lecturas duplicadas

**Métricas**:
```
Lecturas CSV: _____ 
Lecturas Firebase: _____
Coincidencia de valores: _____ / 5
Duplicados encontrados: _____ (debe ser 0)
```

---

## 2. Pruebas de Usabilidad y Accesibilidad

### 2.1 Pruebas de Interfaz Intuitiva

#### PT-009: Tiempo de Aprendizaje (First-Time Users)
**Objetivo**: Medir qué tan rápido un usuario nuevo entiende la app  
**Tipo**: Usabilidad

**Procedimiento**:
1. Seleccionar 5 usuarios sin experiencia previa
2. Darles solo una descripción breve: "App para monitorear calidad del agua"
3. Pedirles completar las siguientes tareas SIN ayuda:
   - Registrarse y hacer login
   - Ver datos de la estación CA-08
   - Cambiar a gráficos históricos
   - Ver datos de los últimos 30 días
   - Interpretar si el agua está en buen estado
4. Cronometrar tiempo por tarea

**Criterios de Éxito**:
- Registro/Login: <3 minutos
- Encontrar datos de estación: <30 segundos
- Cambiar a gráficos: <20 segundos
- Interpretar calidad del agua: <1 minuto
- 4/5 usuarios completan todas las tareas sin ayuda

**Métricas**:
```
Usuario 1: Registro ___min, Ver estación ___s, Gráficos ___s, 30d ___s, Interpretar ___s
Usuario 2: [...]
...
Tasa de éxito: _____ / 5
```

---

#### PT-010: Claridad de Información (System Usability Scale - SUS)
**Objetivo**: Evaluar la usabilidad percibida mediante cuestionario estándar  
**Tipo**: Usabilidad

**Procedimiento**:
1. Después de PT-009, pedir a los usuarios completar SUS
2. Calcular puntuación (0-100)

**Cuestionario SUS** (1=Totalmente en desacuerdo, 5=Totalmente de acuerdo):
1. Creo que me gustaría usar esta app frecuentemente
2. Encontré la app innecesariamente compleja
3. Pensé que la app era fácil de usar
4. Creo que necesitaría ayuda técnica para usar esta app
5. Encontré que las funciones estaban bien integradas
6. Pensé que había mucha inconsistencia en la app
7. Imagino que la mayoría aprendería a usar esta app rápidamente
8. Encontré la app muy incómoda de usar
9. Me sentí muy confiado usando la app
10. Necesité aprender muchas cosas antes de poder usar la app

**Criterios de Éxito**:
- Puntuación SUS: ≥70 (por encima del promedio)
- Puntuación SUS: ≥80 (excelente)

**Métricas**:
```
Puntuación SUS promedio: _____ / 100
Rango: _____ - _____
Usuarios con SUS ≥70: _____ / 5
```

---

#### PT-011: Test de 5 Segundos (First Impression)
**Objetivo**: Validar que la jerarquía visual es clara  
**Tipo**: Usabilidad

**Procedimiento**:
1. Mostrar screenshot del Dashboard a 10 personas por 5 segundos
2. Ocultar imagen
3. Preguntar:
   - ¿Qué información viste?
   - ¿Cuál era el estado del agua?
   - ¿Cuántas estaciones había?
   - ¿Recuerdas algún valor numérico?

**Criterios de Éxito**:
- 8/10 identifican que es monitoreo de agua
- 7/10 recuerdan que hay 3 estaciones
- 6/10 notan los indicadores de estado (colores/iconos)
- 5/10 recuerdan al menos 1 valor (pH, TDS, etc.)

**Métricas**:
```
Identifican propósito: _____ / 10
Recuerdan estaciones: _____ / 10
Notan indicadores: _____ / 10
Recuerdan valores: _____ / 10
```

---

### 2.2 Pruebas de Accesibilidad

#### PT-012: Accesibilidad para Daltonismo
**Objetivo**: Verificar que los colores no son la única forma de distinguir estados  
**Tipo**: Accesibilidad

**Procedimiento**:
1. Usar simulador de daltonismo (Chrome DevTools > Rendering > Emulate vision deficiencies)
2. Probar Protanopia (rojo-verde), Deuteranopia, Tritanopia
3. Verificar que los estados siguen siendo distinguibles

**Criterios de Éxito**:
- Estados distinguibles sin depender del color
- Iconos presentes: ✓ (bueno), ⚠ (advertencia), ✗ (malo)
- Texto descriptivo complementa los colores
- Contraste de texto: ≥4.5:1 (WCAG AA)

**Métricas**:
```
Distinguibilidad sin color: Sí / No
Iconos presentes en todos los estados: Sí / No
Contraste de texto: _____ :1
Cumple WCAG AA: Sí / No
```

---

#### PT-013: Navegación con Teclado/TalkBack
**Objetivo**: Validar accesibilidad para usuarios con discapacidades  
**Tipo**: Accesibilidad

**Procedimiento**:
1. **Android**: Activar TalkBack (Accesibilidad > TalkBack)
2. **iOS**: Activar VoiceOver
3. Intentar completar las tareas:
   - Login
   - Ver datos de estación
   - Cambiar a gráficos
   - Seleccionar período de 30 días
4. Sin tocar la pantalla (solo navegación por voz)

**Criterios de Éxito**:
- Todos los elementos tienen etiquetas descriptivas
- Orden de navegación lógico (top → bottom, left → right)
- Botones anuncian su función claramente
- Gráficos tienen descripción textual alternativa
- Completar flujo principal sin bloqueos

**Métricas**:
```
Elementos sin etiqueta: _____ (debe ser 0)
Orden de navegación lógico: Sí / No
Descripción de gráficos: Sí / No
Flujo completado: Sí / No
```

---

#### PT-014: Tamaño de Elementos Táctiles
**Objetivo**: Verificar que los botones son suficientemente grandes  
**Tipo**: Accesibilidad + Usabilidad

**Procedimiento**:
1. Usar herramienta de medición (DevTools > Ruler)
2. Medir dimensiones de elementos interactivos:
   - Botones de login/registro
   - Tabs de Dashboard/Gráficos
   - Selectores de período (24h, 7d, 30d, 90d)
   - Dropdown de estaciones

**Criterios de Éxito**:
- Todos los elementos: ≥44x44 dp (recomendación Material Design)
- Separación entre elementos: ≥8 dp
- Elementos táctiles no se superponen

**Métricas**:
```
Botones principales: _____ x _____ dp
Tabs: _____ x _____ dp
Selectores: _____ x _____ dp
Elementos <44dp: _____ (debe ser 0)
```

---

### 2.3 Pruebas de Experiencia Multiplataforma

#### PT-015: Consistencia Android vs iOS vs Windows
**Objetivo**: Validar que la experiencia es consistente en todas las plataformas  
**Tipo**: Usabilidad Multiplataforma

**Procedimiento**:
1. Ejecutar app en:
   - Android (teléfono)
   - iOS (iPhone o simulador)
   - Windows (desktop)
2. Comparar:
   - Layout de pantallas
   - Funcionalidad de botones
   - Rendimiento de gráficos
   - Comportamiento de navegación

**Criterios de Éxito**:
- Layout adaptado correctamente a cada plataforma
- Funcionalidad 100% idéntica
- Rendimiento similar (±10% de FPS)
- Navegación respeta convenciones de cada plataforma

**Métricas**:
```
Diferencias visuales significativas: _____ (debe ser 0)
Funcionalidad diferente: _____ (debe ser 0)
FPS Android: _____, iOS: _____, Windows: _____
Navegación nativa: Sí / No
```

---

#### PT-016: Adaptación a Diferentes Tamaños de Pantalla
**Objetivo**: Verificar responsividad en dispositivos diversos  
**Tipo**: Usabilidad

**Procedimiento**:
1. Probar en dispositivos:
   - Smartphone pequeño (4.7", 360x640)
   - Smartphone grande (6.5", 1080x2400)
   - Tablet (10", 1200x1920)
   - Desktop (1920x1080)
2. Verificar que todo el contenido es visible sin scroll horizontal
3. Validar que los gráficos se adaptan correctamente

**Criterios de Éxito**:
- Sin scroll horizontal en ninguna pantalla
- Gráficos legibles en todas las resoluciones
- Texto no truncado ni solapado
- Botones accesibles sin necesidad de zoom

**Métricas**:
```
Scroll horizontal necesario: Sí / No
Gráficos adaptados: Sí / No
Texto legible sin zoom: Sí / No
Layout roto: Sí / No
```

---

## 3. Pruebas Exploratorias Recomendadas

### 3.1 Escenarios de Uso Real

#### PT-017: Monitoreo Durante una Semana Completa
**Objetivo**: Validar estabilidad a largo plazo  
**Tipo**: Prueba de Duración

**Procedimiento**:
1. Instalar app en dispositivo de uso diario
2. Dejar funcionando 7 días seguidos
3. Revisar diariamente:
   - App sigue respondiendo
   - Datos se actualizan correctamente
   - Firebase tiene todas las lecturas esperadas
4. Analizar logs de errores

**Criterios de Éxito**:
- App no se cierra inesperadamente en 7 días
- Firebase contiene ~60 lecturas/día por estación (2/hora × 24h)
- Sin degradación de rendimiento perceptible
- Batería: consumo <5% del total (en modo background)

**Métricas**:
```
Crashes en 7 días: _____ (debe ser 0)
Lecturas esperadas: _____ (60/día × 3 estaciones × 7 días = 1260)
Lecturas registradas: _____
Consumo de batería: _____ %
```

---

#### PT-018: Alternancia Rápida de Conexión
**Objetivo**: Probar resiliencia ante conexión inestable  
**Tipo**: Estrés + Resiliencia

**Procedimiento**:
1. Iniciar app con WiFi activo
2. Durante 10 minutos, alternar cada 30 segundos:
   - WiFi ON → OFF → ON
   - Datos móviles ON → OFF → ON
3. Verificar:
   - App no se cuelga
   - Datos se sincronizan correctamente al reconectar
   - UI muestra estado de conexión (si aplica)

**Criterios de Éxito**:
- Sin crashes durante 10 minutos
- Todas las lecturas offline se sincronizan
- Tiempo de sincronización post-reconexión: <10s
- UI responde durante todo el proceso

**Métricas**:
```
Crashes: _____ (debe ser 0)
Lecturas perdidas: _____ (debe ser 0)
Tiempo máx de sincronización: _____ s
UI bloqueada: Sí / No
```

---

#### PT-019: Múltiples Usuarios Simultáneos
**Objetivo**: Validar que el sistema soporta concurrencia  
**Tipo**: Carga + Concurrencia

**Procedimiento**:
1. Registrar 10 cuentas de usuario
2. Abrir app en 10 dispositivos simultáneamente (o emuladores)
3. Todos los usuarios:
   - Hacen login
   - Navegan por dashboard
   - Cargan gráficos históricos
4. Verificar que todos reciben datos correctos

**Criterios de Éxito**:
- Todos los usuarios logran hacer login
- Datos consistentes entre usuarios
- Sin errores de "too many connections"
- Rendimiento similar para todos los usuarios

**Métricas**:
```
Logins exitosos: _____ / 10
Errores de conexión: _____ (debe ser 0)
Tiempo de carga promedio: _____ s
Diferencias de datos: _____ (debe ser 0)
```

---

### 3.2 Pruebas de Casos Extremos

#### PT-020: Datos Fuera de Rango (Edge Cases)
**Objetivo**: Validar manejo de valores anómalos  
**Tipo**: Robustez

**Procedimiento**:
1. Modificar temporalmente `SensorSimulator` para generar valores extremos:
   - pH: -1, 0, 14, 15
   - TDS: 0, 1000, 10000
   - Turbidez: 0, 100, 1000
   - Temperatura: -10, 0, 50, 100
2. Verificar que la app:
   - No crashea
   - Muestra correctamente el estado (rojo)
   - Guarda los datos en Firebase
   - Gráficos se renderizan sin errores

**Criterios de Éxito**:
- Sin crashes con valores extremos
- Estados de calidad correctos (todos rojos)
- Gráficos muestran todos los valores sin cortar ejes
- Firebase acepta y almacena los valores

**Métricas**:
```
Crashes con valores extremos: _____ (debe ser 0)
Estados incorrectos: _____ (debe ser 0)
Gráficos rotos: _____ (debe ser 0)
Datos guardados en Firebase: Sí / No
```

---

#### PT-021: Base de Datos Vacía
**Objetivo**: Verificar comportamiento sin datos históricos  
**Tipo**: Robustez

**Procedimiento**:
1. Crear nuevo proyecto Firebase (o limpiar datos)
2. Eliminar archivo CSV de assets
3. Ejecutar app
4. Verificar:
   - Login funciona
   - Dashboard muestra mensaje apropiado
   - Gráficos muestran "Sin datos disponibles"
   - No hay crashes

**Criterios de Éxito**:
- App no crashea con DB vacía
- Mensajes informativos claros ("No hay datos históricos")
- UI no muestra widgets vacíos o con errores
- Al generar nuevas lecturas, UI se actualiza correctamente

**Métricas**:
```
Crashes: _____ (debe ser 0)
Mensajes informativos presentes: Sí / No
UI con errores visuales: Sí / No
Actualización tras generar datos: Sí / No
```

---

## 4. Sugerencias Adicionales de Pruebas

### 4.1 Pruebas de Seguridad

**PT-022: Validación de Credenciales**
- Probar login con credenciales inválidas
- Verificar mensajes de error claros
- Intentar SQL injection en campos (debería ser imposible con Firebase)
- Validar que contraseñas débiles son rechazadas

**PT-023: Autenticación y Tokens**
- Verificar que tokens JWT expiran correctamente
- Probar acceso sin login (debe redirigir a login)
- Validar que logout limpia sesión completamente

---

### 4.2 Pruebas de Localización (i18n)

**PT-024: Soporte Multiidioma** (si aplica)
- Verificar que textos en español son correctos
- Probar cambio de idioma del sistema
- Validar que formato de fechas respeta locale

---

### 4.3 Pruebas de Actualización

**PT-025: Migración de Versiones**
- Instalar versión anterior (si existe)
- Actualizar a versión actual
- Verificar que datos locales se migran correctamente
- Validar que no hay pérdida de información

---

## 5. Plan de Ejecución de Pruebas

### Prioridad Alta (Críticas para Release)
1. **PT-001**: Latencia de actualización ✅
2. **PT-002**: Sincronización Firebase ✅
3. **PT-003**: Persistencia offline ✅
4. **PT-009**: Tiempo de aprendizaje ✅
5. **PT-012**: Accesibilidad daltonismo ✅
6. **PT-017**: Monitoreo 7 días ✅

### Prioridad Media (Importantes)
7. **PT-004**: Consumo de memoria
8. **PT-005**: Rendimiento gráficos
9. **PT-007**: Validación umbrales
10. **PT-010**: SUS Score
11. **PT-013**: TalkBack/VoiceOver
12. **PT-015**: Consistencia multiplataforma

### Prioridad Baja (Opcionales)
13. **PT-011**: Test de 5 segundos
14. **PT-014**: Tamaño elementos táctiles
15. **PT-016**: Adaptación pantallas
16. **PT-018**: Alternancia conexión
17. **PT-019**: Múltiples usuarios
18. **PT-020**: Datos extremos
19. **PT-021**: Base de datos vacía

---

## 6. Herramientas Recomendadas

### Para Pruebas de Rendimiento
- **Flutter DevTools**: Análisis de rendimiento y memoria
- **Android Studio Profiler**: CPU, memoria, red (Android)
- **Xcode Instruments**: Análisis de rendimiento (iOS)
- **Firebase Performance Monitoring**: Métricas en producción

### Para Pruebas de Usabilidad
- **Maze.design**: Test remoto de usabilidad
- **UserTesting.com**: Grabación de sesiones de usuarios reales
- **Hotjar**: Heatmaps y grabaciones de sesión

### Para Pruebas de Accesibilidad
- **Accessibility Scanner** (Android)
- **Accessibility Inspector** (Xcode)
- **Chrome DevTools > Lighthouse**: Auditoría de accesibilidad
- **Color Contrast Analyzer**: Verificar contraste WCAG

### Para Pruebas de Integración
- **Firebase Console**: Monitoreo en tiempo real de datos
- **Flutter Integration Tests**: Automatización de flujos completos
- **Postman/Insomnia**: Pruebas de API (si aplica)

---

## 7. Formato de Reporte de Resultados

### Plantilla de Reporte por Prueba

```markdown
## [ID_PRUEBA] - [Nombre de la Prueba]

**Ejecutado por**: _____  
**Fecha**: _____  
**Plataforma**: Android / iOS / Windows  
**Versión de app**: _____  

### Resultados
- Criterio 1: ✅ Aprobado / ❌ Fallido
- Criterio 2: ✅ Aprobado / ❌ Fallido
- ...

### Métricas Obtenidas
- Métrica 1: _____ (esperado: _____)
- Métrica 2: _____ (esperado: _____)

### Observaciones
[Describir cualquier comportamiento inesperado, bugs encontrados, etc.]

### Evidencia
- Screenshot 1: [adjuntar]
- Video: [link]
- Logs: [adjuntar archivo]

### Estado Final
✅ APROBADO / ❌ FALLIDO / ⚠️ APROBADO CON OBSERVACIONES
```

---

## 8. Criterios de Aceptación Global

Para considerar el sistema listo para producción:

### Obligatorios (100% cumplimiento)
- ✅ Todas las pruebas de Prioridad Alta aprobadas
- ✅ Sin crashes en prueba de 7 días
- ✅ Sincronización Firebase funcional (online + offline)
- ✅ SUS Score ≥70

### Deseables (80% cumplimiento)
- 🔵 80% de pruebas de Prioridad Media aprobadas
- 🔵 Rendimiento: FPS ≥55 en todos los dispositivos
- 🔵 Accesibilidad: Cumple WCAG AA
- 🔵 Tiempo de aprendizaje <5 minutos para usuarios nuevos

### Opcionales (mejora continua)
- 🟢 Pruebas de Prioridad Baja: feedback para futuras versiones
- 🟢 Optimizaciones de rendimiento adicionales
- 🟢 Mejoras de UX basadas en feedback de usuarios

---

**Versión del Documento**: 1.0  
**Última Actualización**: 26 de Noviembre, 2025  
**Responsable**: Equipo de QA - Water Quality Analyzer
