# GhostTask BOF — Adaptado para AdaptixC2

Crea y elimina tareas programadas de Windows directamente en el registro,
**sin usar la API del Task Scheduler** (COM/RPC). Esto evita la generación
de los eventos de auditoría 4698 (task created) y 4699 (task deleted).

Técnica original: https://cyber.wtf/2022/06/01/windows-registry-analysis-todays-episode-tasks/

---

## Estructura del proyecto

```
ghost_task_adaptix/
├── Makefile
├── ghost_task.axs          ← Script AXScript para AdaptixC2
├── _bin/                   ← BOFs compilados (generados por make)
│   ├── GhostTask.x64.o
│   └── GhostTask.x86.o
└── src/
    ├── entry.c             ← Punto de entrada del BOF
    ├── ghost_task.c        ← Lógica principal (registro, triggers, acciones)
    ├── ghost_task.h        ← Estructuras de datos
    ├── base.c              ← Helpers (output, UTF conversions, DynamicLoad)
    ├── beacon.h            ← API de Beacon (compatible CS y AdaptixC2)
    └── bofdefs.h           ← Declaraciones de funciones Win32 para BOF
```

---

## Compilación

Requiere `mingw-w64`:

```bash
# Ubuntu/Debian
sudo apt install mingw-w64

# Compilar ambas arquitecturas
make all

# Solo x64
make x64

# Solo x86
make x86

# Limpiar
make clean
```

Los objetos `.o` quedan en `_bin/`.

---

## Instalación en AdaptixC2

1. Compilar el BOF (`make all`).
2. Copiar la carpeta completa (incluyendo `_bin/` y `ghost_task.axs`) al
   directorio de scripts del teamserver.
3. En la interfaz de AdaptixC2: **AxScript Manager → Load Script** →
   seleccionar `ghost_task.axs`.
4. El comando `ghost_task` quedará disponible en la consola de cualquier
   agente Beacon.

---

## Uso

### Crear tarea programada

```
# Tarea diaria a las 22:30, ejecutar cmd.exe como SYSTEM en localhost
ghost_task add -n MiTarea -p C:\Windows\System32\cmd.exe -a "/c whoami > C:\out.txt" -u SYSTEM -s daily -t 22:30

# Tarea que ejecuta cada 60 segundos
ghost_task add -n MiTarea -p C:\Windows\System32\calc.exe -a "" -u SYSTEM -s second -t 60

# Tarea semanal los lunes y viernes a las 09:00
ghost_task add -n MiTarea -p C:\ruta\payload.exe -a "" -u SYSTEM -s weekly -t 09:00 -d monday,friday

# Tarea al logon del usuario
ghost_task add -n MiTarea -p C:\ruta\payload.exe -a "" -u Administrator -s logon

# Contra equipo remoto (requiere admin en el registro remoto)
ghost_task add -c SERVIDOR01 -n MiTarea -p C:\Windows\System32\cmd.exe -a "/c ..." -u SYSTEM -s daily -t 03:00
```

### Eliminar tarea programada

```
# Eliminar tarea local
ghost_task delete -n MiTarea

# Eliminar tarea remota
ghost_task delete -c SERVIDOR01 -n MiTarea
```

---

## Parámetros

| Flag | Nombre      | Descripción                                          | Default   |
|------|-------------|------------------------------------------------------|-----------|
| `-c` | computer    | Equipo remoto. `localhost` = equipo local            | localhost |
| `-n` | taskname    | Nombre de la tarea                                   | —         |
| `-p` | program     | Ruta completa del ejecutable                         | —         |
| `-a` | argument    | Argumentos del ejecutable (usar `""` si ninguno)     | `""`      |
| `-u` | username    | Usuario bajo el que corre la tarea                   | SYSTEM    |
| `-s` | stype       | Tipo de trigger: `second`, `daily`, `weekly`, `logon`| daily     |
| `-t` | time        | `HH:MM` (daily/weekly) o `N` segundos (second)       | 12:00     |
| `-d` | days        | Días para weekly (inglés, separados por coma)        | monday    |

---

## Requisitos

- **Target local**: el agente debe correr en contexto **SYSTEM**.
- **Target remoto**: el agente debe tener acceso administrativo al registro
  remoto del equipo objetivo (puerto 445 / SMB).

> La tarea queda registrada en el registro pero el servicio de tareas
> (`Schedule`) necesita **reiniciarse** para leerla. Esto es inherente a la
> técnica ghost task.

---

## Diferencias respecto al BOF original (Cobalt Strike)

| Aspecto              | Cobalt Strike              | AdaptixC2                            |
|----------------------|----------------------------|--------------------------------------|
| Entry point          | `go(PCHAR, ULONG)`         | Igual — 100% compatible              |
| Output               | `BeaconPrintf`             | Igual — soportado por Adaptix        |
| Arg parsing          | `BeaconDataParse/Extract`  | Igual — soportado por Adaptix        |
| Empaquetado de args  | `bof_pack` de agscript CNA | `ax.bof_pack()` en AXScript          |
| Registro del comando | `.cna` Aggressor Script    | `.axs` AXScript con `create_command` |
| BOF loader           | `inline-execute`           | `execute bof <path> <args>`          |

El código C del BOF **no requiere modificaciones** — la API de Beacon usada
(`BeaconDataParse`, `BeaconDataExtract`, `BeaconDataInt`, `BeaconPrintf`,
`BeaconOutput`) está completamente soportada por AdaptixC2. Solo se
reescribió el script del lado del cliente (`.cna` → `.axs`).
