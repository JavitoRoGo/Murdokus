//
//  RuleModelTests.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 25/11/2026.
//

import Testing
import Foundation
import SwiftUI

@testable import Murdokus

@MainActor
@Suite("Pruebas del Modelo de Reglas y Contexto")
struct RuleModelTests {

	@Test("Un regla debe poder codificarse y decodificarse sin pérdida de datos")
	func gameRuleCodable() throws {
		// Given
		let rule = GameRule(
			person: RulePerson.suspect("A"),
			target: .element(.chair),
			comparison: .equal
		)

		// When
		let data = try JSONEncoder().encode(rule)
		let decodedRule = try JSONDecoder().decode(GameRule.self, from: data)

		// Then
		#expect(decodedRule == rule)
	}

	@Test("Una persona debe identificarse como sospechoso o víctima")
	func rulePersonIdentifiesSuspectOrVictim() {
		// Given / When / Then
		#expect(RulePerson.suspect("A").isVictim == false)
		#expect(RulePerson.suspect("A").capitalLetter == "A")
		#expect(RulePerson.victim.isVictim == true)
		#expect(RulePerson.victim.capitalLetter == nil)
	}

	@Test("La zona debe conservar su índice y su nombre")
	func zoneIDConstruction() {
		// Given
		let zone = ZoneID(index: 2, name: "amarillo")

		// Then
		#expect(zone.index == 2)
		#expect(zone.name == "amarillo")
	}

	@Test("La paleta de zonas debe contener las zonas en orden")
	func zonePaletteContainsAllZones() {
		// Then
		#expect(ZoneID.palette.count == 10)
		#expect(ZoneID.palette.first == ZoneID(index: 0, name: "rojo"))
	}

	@Test("Una celda vacía debe ser ocupable por una persona")
	func emptyCellIsOccupiableByPerson() {
		// Given
		let cell = BoardCell(elements: [], zone: nil)

		// Then
		#expect(cell.isOccupiableByPerson(.victim))
	}

	@Test("Una celda con mueble que soporta apilamiento debe ser ocupable")
	func stackableFurnitureIsOccupiableByPerson() {
		// Given
		let chairCell = BoardCell(elements: [.chair], zone: nil)
		let rugCell = BoardCell(elements: [.rug], zone: nil)

		// Then
		#expect(chairCell.isOccupiableByPerson(.victim))
		#expect(rugCell.isOccupiableByPerson(.victim))
	}

	@Test("Una celda con mueble que no soporta apilamiento no debe ser ocupable")
	func nonStackableFurnitureIsNotOccupiableByPerson() {
		// Given
		let plantCell = BoardCell(elements: [.plant], zone: nil)
		let bookshelfCell = BoardCell(elements: [.bookshelf], zone: nil)
		let tableCell = BoardCell(elements: [.table], zone: nil)

		// Then
		#expect(!plantCell.isOccupiableByPerson(.victim))
		#expect(!bookshelfCell.isOccupiableByPerson(.victim))
		#expect(!tableCell.isOccupiableByPerson(.victim))
	}

	@Test("Una celda con marca X no debe ser ocupable")
	func xMarkedCellIsNotOccupiableByPerson() {
		// Given
		let xMarkedCell = BoardCell(elements: [.xMark], zone: nil)

		// Then
		#expect(!xMarkedCell.isOccupiableByPerson(.victim))
	}

	@Test("Una celda con dos elementos no debe ser ocupable")
	func doubleOccupiedCellIsNotOccupiableByPerson() {
		// Given
		let occupiedCell = BoardCell(elements: [.chair, .rug], zone: nil)

		// Then
		#expect(!occupiedCell.isOccupiableByPerson(.victim))
	}

	@Test("El contexto del motor debe reflejar las dimensiones y los sospechosos")
	func boardContextFromEngineReflectsSetup() {
		// Given
		let engine = GridEngine()
		engine.setupGameWith(rows: 6, columns: 6, suspectsNumber: 5, colors: 3)

		// When
		let context = BoardContextBuilder.context(from: engine)

		// Then
		#expect(context.rows == 6)
		#expect(context.columns == 6)
		#expect(context.suspects.count == 5)
		#expect(context.suspects.first == "A")
		#expect(context.cells.count == 6)
		#expect(context.cells[0].count == 6)
	}

	@Test("El contexto debe derivar la zona pintada en la celda correspondiente")
	func boardContextDerivesPaintedZone() {
		// Given
		let engine = GridEngine()
		engine.setupGameWith(rows: 6, columns: 6, suspectsNumber: 5, colors: 3)
		engine.handleIntent(.changeColor(color: .red, row: 0, col: 0))

		// When
		let context = BoardContextBuilder.context(from: engine)

		// Then
		#expect(context.zones.count == 1)
		#expect(context.zones.first == ZoneID(index: 0, name: "rojo"))
		#expect(context.cells[0][0].zone == ZoneID(index: 0, name: "rojo"))
		#expect(context.cells[0][1].zone == nil)
	}
}
