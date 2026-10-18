import Testing
import SwiftUI
@testable import Murdokus

@Suite("Pruebas del Motor de Cuadrícula (GridEngine)")
struct GridEngineTests {

    @Test("La cuadrícula debe inicializarse con las dimensiones correctas")
    func testGridInitialization() {
        let rows = 5
        let cols = 10
        let engine = GridEngine(rows: rows, columns: cols)
        
        #expect(engine.rows == rows)
        #expect(engine.columns == cols)
        #expect(engine.cells.count == rows)
        #expect(engine.cells.first?.count == cols)
    }

    @Test("Colocar un elemento debe actualizar la celda correcta")
    func testSetElement() {
        let engine = GridEngine(rows: 3, columns: 3)
        let object = MurdokuObject(name: "Sospechoso 1", element: .suspect)
        
        // Probar posición válida
        engine.setElement(object, atRow: 1, col: 1)
        #expect(engine.cells[1][1].element?.name == "Sospechoso 1")
        #expect(engine.cells[1][1].element?.element == .suspect)
        
        // Verificar que el resto de la celda sigue igual (vacía)
        #expect(engine.cells[0][0].element == nil)
        
        // Probar posición fuera de límites (no debe crashear)
        engine.setElement(object, atRow: 5, col: 5)
        engine.setElement(object, atRow: -1, col: 0)
    }

    @Test("Cambiar el color de la habitación debe actualizar la celda correctamente")
    func testSetRoomID() {
        let engine = GridEngine(rows: 3, columns: 3)
        let targetColor = Color.red
        
        engine.setRoomID(targetColor, atRow: 2, col: 2)
        
        #expect(engine.cells[2][2].color == targetColor)
        // Verificar que no afectó a otra celda
        #expect(engine.cells[0][0].color == .secondary)
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
}
