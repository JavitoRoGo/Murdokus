//
//  GridEngineTests.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 19/10/2026.
//

import Testing
import SwiftUI
@testable import Murdokus

@Suite("Pruebas del Motor de Cuadrícula (GridEngine)")
struct GridEngineTests {
	let engine = GridEngine()

	@Test("La cuadrícula debe inicializarse con las dimensiones correctas tras setupGameWith")
	func gridInitialization() {
		let rows = 5
		let cols = 10

		engine.setupGameWith(rows: rows, columns: cols, suspectsNumber: 3, colors: 1)

		#expect(engine.rows == rows)
		#expect(engine.columns == cols)
		#expect(engine.cells.count == rows)
		#expect(engine.cells.first?.count == cols)
		#expect(engine.roomColors.count == 1)
	}

	@Test("Colocar un elemento debe actualizar la celda correcta mediante una intención de movimiento")
	func setElement() {
		engine.setupGameWith(rows: 3, columns: 3, suspectsNumber: 0, colors: 1)
		let object = MurdokuObject(name: "Sospechoso 1", element: .suspect)

		let package = MurdokuTransferPackage(object: object, sourceRow: -1, sourceCol: -1)

		engine.handleIntent(.move(package: package, destinationRow: 1, destinationCol: 1))

		// Antes: engine.cells[1][1].element?.name
		// Ahora: comprobamos el último elemento de la pila
		#expect(engine.cells[1][1].elements.last?.name == "Sospechoso 1")
		#expect(engine.cells[1][1].elements.last?.element == .suspect)
	}

	@Test("Cambiar el color de la habitación debe actualizar la celda correctamente")
	func setRoomColor() {
		engine.setupGameWith(rows: 3, columns: 3, suspectsNumber: 0, colors: 1)
		let targetColor = Color.red

		engine.handleIntent(.changeColor(color: targetColor, row: 2, col: 2))

		#expect(engine.cells[2][2].color == targetColor)
		#expect(engine.cells[0][0].color == Color.secondary.opacity(0.2))
	}

	@Test("MurdokuElement debe devolver canStackOnTop correctamente")
	func elementStackingProperties() {
		#expect(MurdokuElement.chair.canStackOnTop == true)
		#expect(MurdokuElement.bed.canStackOnTop == true)
		#expect(MurdokuElement.rug.canStackOnTop == true)

		#expect(MurdokuElement.suspect.canStackOnTop == false)
		#expect(MurdokuElement.table.canStackOnTop == false)
		#expect(MurdokuElement.xMark.canStackOnTop == false)
	}

	@Test("setupGameWith debe generar los sospechosos con nombres y letras correctas")
	func suspectGeneration() {
		let numSuspects = 3
		engine.setupGameWith(rows: 2, columns: 2, suspectsNumber: numSuspects, colors: 1)

		#expect(engine.suspects.count == numSuspects)
		#expect(engine.suspects.first?.name == "Sospechoso A")
		#expect(engine.suspects.first?.capitalLetter == "A")
	}

	@Test("resetGame debe limpiar completamente el estado del motor")
	func resetGame() {
		engine.setupGameWith(rows: 3, columns: 3, suspectsNumber: 2, colors: 1)

		engine.resetGame()

		#expect(engine.rows == 0)
		#expect(engine.columns == 0)
		#expect(engine.cells.isEmpty)
		#expect(engine.suspects.isEmpty)
	}

	@Test("Los métodos de escritura deben ignorar índices fuera de los límites (Sin crash)")
	func boundsChecking() {
		let rows = 3
		let cols = 3
		engine.setupGameWith(rows: rows, columns: cols, suspectsNumber: 0, colors: 1)
		let object = MurdokuObject(name: "Test", element: .chair)

		let package = MurdokuTransferPackage(object: object, sourceRow: 1, sourceCol: 1)
		engine.handleIntent(.move(package: package, destinationRow: 1, destinationCol: 1))
		engine.handleIntent(.move(package: package, destinationRow: 5, destinationCol: 1))
		engine.handleIntent(.move(package: package, destinationRow: 1, destinationCol: 5))

		#expect(engine.cells[1][1].elements.last?.name == "Test")
	}

	@Test("Limpiar una celda mediante intención de borrado")
	func clearCell() {
		engine.setupGameWith(rows: 3, columns: 3, suspectsNumber: 0, colors: 1)
		let object = MurdokuObject(name: "Mesa", element: .table)

		let packagePre = MurdokuTransferPackage(object: object, sourceRow: -1, sourceCol: -1)
		engine.handleIntent(.move(package: packagePre, destinationRow: 1, destinationCol: 1))

		#expect(engine.cells[1][1].elements.count > 0)

		let packageDel = MurdokuTransferPackage(object: object, sourceRow: 1, sourceCol: 1)
		engine.handleIntent(.delete(package: packageDel))

		#expect(engine.cells[1][1].elements.isEmpty)
	}

	@Test("Limpiar fuera de límites debe ser seguro")
	func clearCellOutOfBounds() {
		engine.setupGameWith(rows: 3, columns: 3, suspectsNumber: 0, colors: 1)

		let dummyObject = MurdokuObject(name: "Dummy", element: .table)
		let package = MurdokuTransferPackage(object: dummyObject, sourceRow: -1, sourceCol: 5)

		engine.handleIntent(.delete(package: package))

		#expect(engine.cells[1][1].elements.isEmpty)
	}

	@Test("Colocar un objeto no debe afectar a las celdas adyacentes")
	func placementSideEffects() {
		engine.setupGameWith(rows: 3, columns: 3, suspectsNumber: 0, colors: 1)
		let object = MurdokuObject(name: "Planta", element: .plant)
		let package = MurdokuTransferPackage(object: object, sourceRow: -1, sourceCol: -1)

		engine.handleIntent(.move(package: package, destinationRow: 1, destinationCol: 1))

		#expect(engine.cells[0][1].elements.isEmpty)
		#expect(engine.cells[1][0].elements.isEmpty)
		#expect(engine.cells[1][2].elements.isEmpty)
		#expect(engine.cells[2][1].elements.isEmpty)
	}

	@Test("Al colocar un sospechoso, se deben añadir marcas X en su fila y columna")
	func applyXMarkRulesBasic() {
		engine.setupGameWith(rows: 3, columns: 3, suspectsNumber: 0, colors: 1)
		let suspect = MurdokuObject(name: "Sospechoso A", element: .suspect)
		let package = MurdokuTransferPackage(object: suspect, sourceRow: -1, sourceCol: -1)

		// Colocamos el sospechoso en la posición central (1, 1)
		engine.handleIntent(.move(package: package, destinationRow: 1, destinationCol: 1))

		// Las celdas (1,0), (1,2), (0,1) y (2,1) deben tener una X
		#expect(engine.cells[1][0].elements.contains { $0.element == .xMark })
		#expect(engine.cells[1][2].elements.contains { $0.element == .xMark })
		#expect(engine.cells[0][1].elements.contains { $0.element == .xMark })
		#expect(engine.cells[2][1].elements.contains { $0.element == .xMark })

		// La celda destino (1,1) NO debe tener una X
		#expect(engine.cells[1][1].elements.contains { $0.element != .xMark })
	}

	@Test("Las marcas X deben añadirse ENCIMA de objetos existentes sin eliminarlos")
	func applyXMarkRulesOverlay() {
		engine.setupGameWith(rows: 3, columns: 3, suspectsNumber: 0, colors: 1)
		let chair = MurdokuObject(name: "Silla", element: .chair)
		let packageChair = MurdokuTransferPackage(object: chair, sourceRow: -1, sourceCol: -1)
		engine.handleIntent(.move(package: packageChair, destinationRow: 1, destinationCol: 0))

		// Colocamos un sospechoso en (1, 2) -> Comparte la fila 1 con la silla
		let suspect = MurdokuObject(name: "Sospechoso A", element: .suspect)
		let packageSuspect = MurdokuTransferPackage(object: suspect, sourceRow: -1, sourceCol: -1)
		engine.handleIntent(.move(package: packageSuspect, destinationRow: 1, destinationCol: 2))

		// La celda (1, 0) debe contener AMBOS elementos: la silla y la X
		let cellElements = engine.cells[1][0].elements
		#expect(cellElements.contains { $0.element == .chair })
		#expect(cellElements.contains { $0.element == .xMark })
		#expect(cellElements.count == 2)
	}
	
	@Test("allSuspectsPlaced debe ser false mientras no se hayan colocado todos los sospechosos")
	func allSuspectsPlacedInitiallyFalse() {
		engine.setupGameWith(rows: 3, columns: 3, suspectsNumber: 2, colors: 1)
		#expect(engine.allSuspectsPlaced == false)
	}

	@Test("allSuspectsPlaced debe ser true cuando se colocan todos los sospechosos")
	func allSuspectsPlacedAfterPlacingAll() {
		engine.setupGameWith(rows: 3, columns: 3, suspectsNumber: 2, colors: 1)
		
		let suspectA = MurdokuObject(name: "Sospechoso A", element: .suspect, capitalLetter: "A")
		engine.handleIntent(.move(package: MurdokuTransferPackage(object: suspectA, sourceRow: -1, sourceCol: -1), destinationRow: 0, destinationCol: 0))
		
		let suspectB = MurdokuObject(name: "Sospechoso B", element: .suspect, capitalLetter: "B")
		engine.handleIntent(.move(package: MurdokuTransferPackage(object: suspectB, sourceRow: -1, sourceCol: -1), destinationRow: 1, destinationCol: 1))
		
		#expect(engine.allSuspectsPlaced == true)
		#expect(engine.suspects.first { $0.capitalLetter == "A" }?.isPlaced == true)
		#expect(engine.suspects.first { $0.capitalLetter == "B" }?.isPlaced == true)
	}

	@Test("Colocar la víctima debe detener el temporizador")
	func victimPlacementStopsTimer() {
		engine.setupGameWith(rows: 3, columns: 3, suspectsNumber: 1, colors: 1)
		engine.handleTimer(.start)
		#expect(engine.isTimerRunning == true)
		
		let victim = MurdokuObject(name: "Víctima", element: .victim)
		engine.handleIntent(.move(package: MurdokuTransferPackage(object: victim, sourceRow: -1, sourceCol: -1), destinationRow: 1, destinationCol: 1))
		
		#expect(engine.isTimerRunning == false)
	}

	@Test("Colocar un elemento que no sea la víctima no debe detener el temporizador")
	func nonVictimPlacementKeepsTimerRunning() {
		engine.setupGameWith(rows: 3, columns: 3, suspectsNumber: 0, colors: 1)
		engine.handleTimer(.start)
		#expect(engine.isTimerRunning == true)
		
		let chair = MurdokuObject(name: "Silla", element: .chair)
		engine.handleIntent(.move(package: MurdokuTransferPackage(object: chair, sourceRow: -1, sourceCol: -1), destinationRow: 1, destinationCol: 1))
		
		#expect(engine.isTimerRunning == true)
	}
}
