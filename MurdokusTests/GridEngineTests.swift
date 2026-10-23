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
	func testGridInitialization() {
		let rows = 5
		let cols = 10
		
		engine.setupGameWith(rows: rows, columns: cols, suspectsNumber: 3)
		
		#expect(engine.rows == rows)
		#expect(engine.columns == cols)
		#expect(engine.cells.count == rows)
		#expect(engine.cells.first?.count == cols)
	}
	
	@Test("Colocar un elemento debe actualizar la celda correcta mediante una intención de movimiento")
	func testSetElement() {
		engine.setupGameWith(rows: 3, columns: 3, suspectsNumber: 0)
		let object = MurdokuObject(name: "Sospechoso 1", element: .suspect)
		
		let package = MurdokuTransferPackage(object: object, sourceRow: -1, sourceCol: -1)
		
		engine.handleIntent(.move(package: package, destinationRow: 1, destinationCol: 1))
		
		// Antes: engine.cells[1][1].element?.name
		// Ahora: comprobamos el último elemento de la pila
		#expect(engine.cells[1][1].elements.last?.name == "Sospechoso 1")
		#expect(engine.cells[1][1].elements.last?.element == .suspect)
	}
	
	@Test("Cambiar el color de la habitación debe actualizar la celda correctamente")
	func testSetRoomColor() {
		engine.setupGameWith(rows: 3, columns: 3, suspectsNumber: 0)
		let targetColor = Color.red
		
		engine.setRoomColor(targetColor, atRow: 2, col: 2)
		
		#expect(engine.cells[2][2].color == targetColor)
		#expect(engine.cells[0][0].color == Color.secondary.opacity(0.2))
	}
	
	@Test("MurdokuElement debe devolver canStackOnTop correctamente")
	func testElementStackingProperties() {
		#expect(MurdokuElement.chair.canStackOnTop == true)
		#expect(MurdokuElement.bed.canStackOnTop == true)
		#expect(MurdokuElement.rug.canStackOnTop == true)
		
		#expect(MurdokuElement.suspect.canStackOnTop == false)
		#expect(MurdokuElement.table.canStackOnTop == false)
		#expect(MurdokuElement.xMark.canStackOnTop == false)
	}
	
	@Test("setupGameWith debe generar los sospechosos con nombres y letras correctas")
	func testSuspectGeneration() {
		let numSuspects = 3
		engine.setupGameWith(rows: 2, columns: 2, suspectsNumber: numSuspects)
		
		#expect(engine.suspects.count == numSuspects)
		#expect(engine.suspects[0].name == "Sospechoso A")
		#expect(engine.suspects[0].capitalLetter == "A")
	}
	
	@Test("resetGame debe limpiar completamente el estado del motor")
	func testResetGame() {
		engine.setupGameWith(rows: 3, columns: 3, suspectsNumber: 2)
		
		engine.resetGame()
		
		#expect(engine.rows == 0)
		#expect(engine.columns == 0)
		#expect(engine.cells.isEmpty)
		#expect(engine.suspects.isEmpty)
	}
	
	@Test("Los métodos de escritura deben ignorar índices fuera de los límites (Sin crash)")
	func testBoundsChecking() {
		let rows = 3
		let cols = 3
		engine.setupGameWith(rows: rows, columns: cols, suspectsNumber: 0)
		let object = MurdokuObject(name: "Test", element: .chair)
		
		let package = MurdokuTransferPackage(object: object, sourceRow: 1, sourceCol: 1)
		engine.handleIntent(.move(package: package, destinationRow: 1, destinationCol: 1))
		engine.handleIntent(.move(package: package, destinationRow: 5, destinationCol: 1))
		engine.handleIntent(.move(package: package, destinationRow: 1, destinationCol: 5))
		
		#expect(engine.cells[1][1].elements.last?.name == "Test")
	}

    @Test("Limpiar una celda mediante intención de borrado")
    func testClearCell() {
        engine.setupGameWith(rows: 3, columns: 3, suspectsNumber: 0)
        let object = MurdokuObject(name: "Mesa", element: .table)
        
        let packagePre = MurdokuTransferPackage(object: object, sourceRow: -1, sourceCol: -1)
		engine.handleIntent(.move(package: packagePre, destinationRow: 1, destinationCol: 1))
        
        #expect(engine.cells[1][1].elements.count > 0)
        
        let packageDel = MurdokuTransferPackage(object: object, sourceRow: 1, sourceCol: 1)
        engine.handleIntent(.delete(package: packageDel))
        
        #expect(engine.cells[1][1].elements.isEmpty)
    }

	@Test("Limpiar fuera de límites debe ser seguro")
	func testClearCellOutOfBounds() {
		engine.setupGameWith(rows: 3, columns: 3, suspectsNumber: 0)
		
		let dummyObject = MurdokuObject(name: "Dummy", element: .table)
		let package = MurdokuTransferPackage(object: dummyObject, sourceRow: -1, sourceCol: 5)
		
		engine.handleIntent(.delete(package: package))
		
		#expect(true)
	}

	@Test("Colocar un objeto no debe afectar a las celdas adyacentes")
	func testPlacementSideEffects() {
		engine.setupGameWith(rows: 3, columns: 3, suspectsNumber: 0)
		let object = MurdokuObject(name: "Planta", element: .plant)
		let package = MurdokuTransferPackage(object: object, sourceRow: -1, sourceCol: -1)
		
		engine.handleIntent(.move(package: package, destinationRow: 1, destinationCol: 1))
		
		#expect(engine.cells[0][1].elements.isEmpty)
		#expect(engine.cells[1][0].elements.isEmpty)
		#expect(engine.cells[1][2].elements.isEmpty)
		#expect(engine.cells[2][1].elements.isEmpty)
	}
}
