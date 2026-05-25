# Rincon Sabor Flutter

Rincon Sabor Flutter es una aplicación móvil desarrollada en Flutter para gestionar las operaciones de un restaurante, incluyendo la toma de pedidos, la gestión de mesas y la coordinación entre meseros y cocineros.

## backend de la app para que funcione la base de datos :D


## Requisitos Previos

- Flutter SDK 3.7.2 o superior
- Dart 3.9.0 o superior
- Android Studio o Visual Studio Code
- Emulador o dispositivo físico para pruebas


## Uso de Git Flow de manera correcta

Este proyecto utiliza **Git Flow** como estrategia de ramificación para mantener un flujo de trabajo organizado. Las reglas básicas son:

1. **Rama Principal (`main-master`)**: Esta rama contiene el código en producción y **no debe ser editada directamente**.
2. **Rama de Desarrollo (`develop`)**: Aquí se integran las nuevas funcionalidades antes de ser lanzadas a producción.
3. **Ramas de Funcionalidad (`feature`)**: Se crean a partir de `develop` para trabajar en nuevas características. Ejemplo:
    ```bash
    git checkout -b feature/nueva-funcionalidad develop
    ```
4. **Ramas de Corrección (`hotfix`)**: Se crean a partir de `main` para corregir errores críticos en producción. Ejemplo:
    ```bash
    git checkout -b hotfix/correccion-critica main
    ```
5. **Ramas de Lanzamiento (`release`)**: Se crean a partir de `develop` para preparar una nueva versión antes de fusionarla en `main`.

### Flujo Básico

- Trabaja en una rama `feature` y, al finalizar, fusiónala en `develop`.
- Antes de lanzar una nueva versión, crea una rama `release` desde `develop` y realiza pruebas.
- Una vez lista, fusiona la rama `release` en `main` y `develop`.
- Para correcciones urgentes, utiliza una rama `hotfix` y fusiónala en `main` y `develop`.


# Estructura del Proyecto

Este proyecto está organizado por funcionalidades y responsabilidades, facilitando la escalabilidad y el mantenimiento del código.

```
lib/
├── core/
│   ├── constants/         # Constantes globales
│   ├── utils/             # Funciones utilitarias
│   ├── widgets/           # Widgets reutilizables (como AccordionManager)
│   └── theme/             # Colores, estilos, fuentes, etc.
│
├── data/
│   ├── models/            # Modelos de datos (EstadoPedido, Plato, etc.)
│   ├── repositories/      # Lógica de acceso a datos simulada o por API
│   └── mock/              # Datos simulados para pruebas
│
├── features/
│   ├── main/
│   │   └── presentation/
│   │       └── screens/   # MainScreen (antes MainActivity)
│   │
│   ├── mesero/
│   │   ├── presentation/
│   │   │   ├── screens/   # MeseroScreen (antes MeseroActivity)
│   │   │   └── widgets/   # Componentes de UI como items del pedido, mesas, etc.
│   │   └── viewmodel/     # Lógica de estado para el módulo de meseros
│   │
│   ├── cocinero/
│   │   ├── presentation/
│   │   │   └── screens/   # CocineroScreen (antes CocineroActivity)
│   │   └── viewmodel/     # Lógica de estado para el módulo de cocina
│
├── routes/
│   └── app_router.dart    # Lógica de navegación centralizada
│
└── main.dart              # Punto de entrada de la aplicación
```

