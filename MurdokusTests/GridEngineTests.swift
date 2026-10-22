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
	
	@Test("Colocar un elemento debe actualizar la celda correcta")
	func testSetElement() {
		engine.setupGameWith(rows: 3, columns: 3, suspectsNumber: 0)
		let object = MurdokuObject(name: "Sospechoso 1", element: .suspect)
		
		// Probar posición válida
		engine.setElement(object, atRow: 1, col: 1)
		#expect(engine.cells[1][1].element?.name == "Sospechoso 1")
		#expect(engine.cells[1][1].element?.element == .suspect)
		
		// Verificar que el resto de la celda sigue igual (vacía)
		#expect(engine.cells[0][0].element == nil)
	}
	
	@Test("Cambiar el color de la habitación debe actualizar la celda correctamente")
	func testSetRoomColor() {
		engine.setupGameWith(rows: 3, columns: 3, suspectsNumber: 0)
		let targetColor = Color.red
		
		engine.setRoomColor(targetColor, atRow: 2, col: 2)
		
		#expect(engine.cells[2][2].color == targetColor)
		// Verificar que no afectó a otra celda (el color inicial es .secondary.opacity(0.2))
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
		#expect(engine.suspects[1].name == "Sospechoso B")
		#expect(engine.suspects[1].capitalLetter == "B")
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
		
		// Límites superiores (El índice máximo es 2 para un tamaño de 3)
		engine.setElement(object, atRow: 3, col: 1)
		engine.setRoomColor(.blue, atRow: 1, col: 3)
		
		// Límites inferiores
		engine.setElement(object, atRow: -1, col: 0)
		engine.setRoomColor(.blue, atRow: 0, col: -1)
		
		// Verificar que la celda [2][2] (la última válida) sigue intacta
		#expect(engine.cells[2][2].element == nil)
	}
	
	@Test("La lista de objetos disponibles debe excluir al sospechoso")
	func testAvailableObjects() {
		let elementsWithoutSuspect = engine.objects.map { $0.element }
		
		#expect(!elementsWithoutSuspect.contains(.suspect))
		#expect(elementsWithoutSuspect.count == MurdokuElement.allCases.count - 1)
	}
	
	@Test("Limpiar una celda debe dejarla vacía")
	func testClearCell() {
		engine.setupGameWith(rows: 3, columns: 3, suspectsNumber: 0)
		let object = MurdokuObject(name: "Mesa", element: .table)
		
		// Colocar y luego limpiar
		engine.setElement(object, atRow: 1, col: 1)
		#expect(engine.cells[1][1].element != nil)
		
		engine.clearCell(atRow: 1, col: 1)
		#expect(engine.cells[1][1].element == nil)
	}

	@Test("Limpiar fuera de límites debe ser seguro")
	func testClearCellOutOfBounds() {
		engine.setupGameWith(rows: 3, columns: 3, suspectsNumber: 0)
		
		// Probar índices negativos y excedentes
		engine.clearCell(atRow: -1, col: 0)
		engine.clearCell(atRow: 3, col: 3)
		
		// Si llegamos aquí sin crash, el test pasa
		#expect(true)
	}

	@Test("Colocar un objeto no debe afectar a las celdas adyacentes")
	func testPlacementSideEffects() {
		engine.setupGameWith(rows: 3, columns: 3, suspectsNumber: 0)
		let object = MurdokuObject(name: "Planta", element: .plant)
		
		engine.setElement(object, atRow: 1, col: 1)
		
		// Verificar que las celdas vecinas siguen vacías
		#expect(engine.cells[0][1].element == nil)
		#expect(engine.cells[1][0].element == nil)
		#expect(engine.cells[1][2].element == nil)
		#expect(engine.cells[2][1].element == nil)
	}
}
