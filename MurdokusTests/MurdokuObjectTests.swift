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

@Suite("Pruebas de Serialización de Objetos")
struct MurdokuObjectTests {

    @Test("Un objeto debe poder codificarse y decodificarse sin pérdida de datos")
    func testObjectCodable() async throws {
        // Given
        let originalObject = MurdokuObject(
            name: "Sospechoso X", 
            element: .suspect, 
            capitalLetter: "X"
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
    }
	
	@Test("El identificador de UTType debe ser el correcto para evitar colisiones")
	func testUTTypeIdentifier() {
		let expectedIdentifier = "com.murdoku.object"
		#expect(UTType.murdokuObject.identifier == expectedIdentifier)
	}
}
