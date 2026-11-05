//
//  MurdokuObjectTests.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 20/10/2026.
//

import Testing
import Foundation
import UniformTypeIdentifiers

@testable import Murdokus

@Suite("Pruebas de Serialización y Transferencia")
struct MurdokuObjectTests {

	@Test("Un objeto debe poder codificarse y decodificarse sin pérdida de datos")
	func objectCodable() throws {
		// Given
		let originalObject = MurdokuObject(
			name: "Sospechoso X",
			element: .suspect,
			capitalLetter: "X",
			isPlaced: true
		)
		let encoder = JSONEncoder()
		let decoder = JSONDecoder()

		// When
		let data = try encoder.encode(originalObject)
		let decodedObject = try decoder.decode(MurdokuObject.self, from: data)

		// Then
		#expect(decodedObject.name == originalObject.name)
		#expect(decodedObject.element == originalObject.element)
		#expect(decodedObject.capitalLetter == originalObject.capitalLetter)
		#expect(decodedObject.isPlaced == originalObject.isPlaced)
	}

	@Test("El identificador de UTType debe ser el correcto para evitar colisiones")
	func utTypeIdentifier() {
		let expectedIdentifier = "com.murdoku.object"
		#expect(UTType.murdokuObject.identifier == expectedIdentifier)
	}

	@Test("El paquete de transferencia debe codificarse y decodificarse correctamente")
	func transferPackage() throws {
		let object = MurdokuObject(name: "Test", element: .chair)
		let package = MurdokuTransferPackage(object: object, sourceRow: 1, sourceCol: 2)

		let encoder = JSONEncoder()
		let decoder = JSONDecoder()

		let data = try encoder.encode(package)
		let decodedPackage = try decoder.decode(MurdokuTransferPackage.self, from: data)

		#expect(decodedPackage.object.name == "Test")
		#expect(decodedPackage.object.element == .chair)
		#expect(decodedPackage.sourceRow == 1)
		#expect(decodedPackage.sourceCol == 2)
	}

	@Test("El snapshot de partida debe codificarse y decodificarse sin pérdida de datos")
	func savedGameSnapshotCodable() throws {
		let cell = SavedGameCell(
			elements: [MurdokuObject(name: "Sospechoso A", element: .suspect, capitalLetter: "A", isPlaced: true)],
			color: SavedGameColor(red: 1.0, green: 0.0, blue: 0.0, opacity: 0.3)
		)
		let snapshot = SavedGameSnapshot(
			rows: 2,
			columns: 3,
			colors: 2,
			suspectsNumber: 2,
			cells: [[cell, cell, cell], [cell, cell, cell]]
		)

		let data = try SavedGameSnapshot.encode(snapshot)
		let decoded = try SavedGameSnapshot.decode(from: data)

		#expect(decoded.rows == snapshot.rows)
		#expect(decoded.columns == snapshot.columns)
		#expect(decoded.colors == snapshot.colors)
		#expect(decoded.suspectsNumber == snapshot.suspectsNumber)
		#expect(decoded.cells.count == snapshot.cells.count)
		#expect(decoded.cells[0][0].elements.count == 1)
		#expect(decoded.cells[0][0].elements.first?.name == "Sospechoso A")
		#expect(decoded.cells[0][0].color.red == 1.0)
		#expect(decoded.cells[0][0].color.opacity == 0.3)
	}
}
