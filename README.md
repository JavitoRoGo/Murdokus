# 🎯 Murdokus

A SwiftUI puzzle game for macOS where you place suspects and objects on a grid, apply X-mark rules, and race against the timer to solve each unique configuration.

## 📖 Overview

**Murdokus** is a logic-based puzzle game built with SwiftUI. The objective is to strategically place suspects and various room elements (chairs, tables, rugs, plants, beds, bookshelves, TVs) on a grid while following stacking and placement rules. X-marks appear to block cells and prevent certain placements, adding an extra layer of challenge. Track your time, save progress, and compete to solve puzzles faster!

## ✨ Features

- 🧩 **Grid-based gameplay** – Configure rows, columns, number of suspects, and room colors
- 👥 **Suspect placement** – Place and toggle candidate markers for up to 8 suspects (A–H)
- 🪞 **X-mark rules** – Automatically apply row/column blockages when a suspect is placed
- 🎨 **Room coloring** – Paint cells with a palette of 10 distinct colors
- ⏱️ **Timer** – Real-time elapsed time tracking with start/pause/reset
- 💾 **Save & load** – Save game snapshots and resume later from your saved games list
- 🗑️ **Trash management** – Remove placed objects and clear the board
- 📊 **Solved state detection** – Automatic detection when a victim is placed; display solve time
- 🔍 **Preview support** – SwiftUI previews for rapid development

## 🎮 How to Play

1. **Configure the board** – Use the sidebar to set the number of rows/columns, suspects, and room colors.
2. **Place suspects** – Select a suspect letter and tap a grid cell to place it. X-marks will appear in the same row/column.
3. **Add room elements** – Drag chairs, tables, rugs, plants, beds, bookshelves, or TVs onto cells. Some elements can support stacking.
4. **Paint cells** – Select a color from the palette and tap a cell to change its background.
5. **Find the victim** – Place the victim object to stop the timer and mark the game as solved.
6. **Save your progress** – Click "Guardar tiempo" to save your solve time, or load a previous game from the sidebar.

## 🛠️ Built With

- **SwiftUI** – Modern declarative UI framework
- **Swift Testing** – Unit tests for game logic

## 📦 Installation

1. Clone the repository: `git clone <repo-url>`
2. Open `Murdokus.xcodeproj` in Xcode
3. Build and run: `xcodebuild -project Murdokus.xcodeproj -scheme Murdokus build`
4. To test: `xcodebuild -project Murdokus.xcodeproj -scheme Murdokus test`

## 🙏 Credits

Created by **Javier Rodríguez Gómez** in October 2026.

---

## 📖 Descripción General

**Murdokus** es un juego de acertijos lógicos para macOS construido con SwiftUI. El objetivo es colocar estratégicamente sospechosos y diversos elementos de sala (sillas, mesas, alfombras, plantas, camas, estanterías, televisores) en una cuadrícula siguiendo reglas de apilamiento y colocación. Las marcas X aparecen para bloquear celdas y impedir ciertas colocaciones, añadiendo una capa adicional de desafío. Controla tu tiempo, guarda el progreso y compite por resolver los acertijos más rápido.

## ✨ Características

- 🧩 **Juego basado en cuadrícula** – Configura filas, columnas, número de sospechosos y colores de sala
- 👥 **Colocación de sospechosos** – Coloca y marca candidatos para hasta 8 sospechosos (A–H)
- 🪞 **Reglas de marca X** – Aplica automáticamente bloqueos en la fila/columna al colocar un sospechoso
- 🎨 **Coloreado de habitaciones** – Pinta celdas con una paleta de 10 colores distintivos
- ⏱️ **Cronómetro** – Seguimiento del tiempo transcurrido en tiempo real con inicio/pausa/reinicio
- 💾 **Guardar y cargar** – Guarda instantáneas del juego y reanuda más tarde desde tu lista de partidas guardadas
- 🗑️ **Gestión de la basura** – Elimina objetos colocados y limpia el tablero
- 📊 **Detección de estado resuelto** – Detección automática al colocar la víctima; muestra el tiempo de solución
- 🔍 **Vistas previas** – Previews de SwiftUI para desarrollo rápido

## 🎮 Cómo Jugar

1. **Configura el tablero** – Usa la barra lateral para establecer el número de filas/columnas, sospechosos y colores de sala.
2. **Coloca sospechosos** – Selecciona una letra de sospechoso y toca una celda de la cuadrícula para colocarlo. Aparecerán marcas X en la misma fila/columna.
3. **Añade elementos de sala** – Arrastra sillas, mesas, alfombras, plantas, camas, estanterías o televisores a las celdas. Algunos elementos admiten apilamiento.
4. **Pinta celdas** – Selecciona un color de la paleta y toca una celda para cambiar su color de fondo.
5. **Encuentra la víctima** – Coloca el objeto víctima para detener el cronómetro y marcar el juego como resuelto.
6. **Guarda tu progreso** – Haz clic en "Guardar tiempo" para guardar tu tiempo de resolución, o carga una partida anterior desde la barra lateral.

## 🛠️ Tecnologías Utilizadas

- **SwiftUI** – Framework declarativo de interfaz de usuario
- **Swift Testing** – Pruebas unitarias para la lógica del juego

## 📦 Instalación

1. Clona el repositorio: `git clone <url-del-repositorio>`
2. Abre `Murdokus.xcodeproj` en Xcode
3. Compila y ejecuta: `xcodebuild -project Murdokus.xcodeproj -scheme Murdokus build`
4. Para probar: `xcodebuild -project Murdokus.xcodeproj -scheme Murdokus test`

## 🙏 Créditos

Creado por **Javier Rodríguez Gómez** en octubre de 2026.