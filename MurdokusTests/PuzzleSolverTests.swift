//
//  PuzzleSolverTests.swift
//  Murdokus
//

import Testing
import Foundation
import SwiftUI

@testable import Murdokus

@MainActor
@Suite("Pruebas del Solver de Reglas")
struct PuzzleSolverTests {
	let engine = GridEngine()
	
	// MARK: - Golden test
	
	@Test("El puzzle de referencia debe tener una víctima única")
	func referencePuzzleHasUniqueVictim() throws {
		// Given
		engine.setupGameWith(rows: 6, columns: 6, suspectsNumber: 5, colors: 3)
		engine.handleIntent(.placeObject(object: MurdokuObject(name: "Silla", element: .chair), row: 0, col: 3))
		engine.handleIntent(.placeObject(object: MurdokuObject(name: "Planta", element: .plant), row: 1, col: 1))
		engine.handleIntent(.placeObject(object: MurdokuObject(name: "Alfombra", element: .rug), row: 4, col: 1))
		engine.handleIntent(.placeObject(object: MurdokuObject(name: "Estantería", element: .bookshelf), row: 2, col: 3))
		engine.handleIntent(.changeColor(color: .red.opacity(0.3), row: 3, col: 4))
		engine.handleIntent(.changeColor(color: .blue.opacity(0.3), row: 2, col: 5))
		engine.handleIntent(.changeColor(color: .yellow.opacity(0.3), row: 0, col: 0))
		let context = BoardContextBuilder.context(from: engine)
		let interpreter = DeterministicRuleParser()
		var rules: [GameRule] = []
		var generalRules: [GeneralRule] = []
		for text in [
			"A estaba junto a una planta",
			"C estaba sobre una alfombra",
			"B estaba al sur de C",
			"D era la unica persona sentada en una silla",
			"E estaba en la zona roja",
			"La víctima estaba en la zona azul",
			"Ningún sospechoso estaba junto a una estantería",
		] {
			let interpreted = try interpreter.interpret(text: text, context: context)
			rules.append(contentsOf: interpreted.rules)
			generalRules.append(contentsOf: interpreted.generalRules)
		}
		
		// When
		let result = PuzzleSolver.solve(context: context, rules: rules, generalRules: generalRules)
		
		// Then
		var victimCell: CellKey?
		var placements: [String: CellKey] = [:]
		if case .uniqueVictim(let foundVictim, let foundPlacements) = result {
			victimCell = foundVictim
			placements = foundPlacements
		}
		#expect(victimCell == CellKey(row: 2, col: 5), "La víctima única debe estar en la fila 3, columna 6 (0-indexed (2,5)).")
		#expect(placements["A"] == CellKey(row: 1, col: 0))
		#expect(placements["B"] == CellKey(row: 5, col: 2))
		#expect(placements["C"] == CellKey(row: 4, col: 1))
		#expect(placements["D"] == CellKey(row: 0, col: 3))
		#expect(placements["E"] == CellKey(row: 3, col: 4))
	}
	
	// MARK: - Performance
	
	@Test("El solver debe resolver el puzzle de referencia en menos de 50 ms")
	func referencePuzzleSolvesQuickly() throws {
		// Given
		engine.setupGameWith(rows: 6, columns: 6, suspectsNumber: 5, colors: 3)
		engine.handleIntent(.placeObject(object: MurdokuObject(name: "Silla", element: .chair), row: 0, col: 3))
		engine.handleIntent(.placeObject(object: MurdokuObject(name: "Planta", element: .plant), row: 1, col: 1))
		engine.handleIntent(.placeObject(object: MurdokuObject(name: "Alfombra", element: .rug), row: 4, col: 1))
		engine.handleIntent(.placeObject(object: MurdokuObject(name: "Estantería", element: .bookshelf), row: 2, col: 3))
		engine.handleIntent(.changeColor(color: .red.opacity(0.3), row: 3, col: 4))
		engine.handleIntent(.changeColor(color: .blue.opacity(0.3), row: 2, col: 5))
		engine.handleIntent(.changeColor(color: .yellow.opacity(0.3), row: 0, col: 0))
		let context = BoardContextBuilder.context(from: engine)
		let interpreter = DeterministicRuleParser()
		var rules: [GameRule] = []
		var generalRules: [GeneralRule] = []
		for text in [
			"A estaba junto a una planta",
			"C estaba sobre una alfombra",
			"B estaba al sur de C",
			"D era la unica persona sentada en una silla",
			"E estaba en la zona roja",
			"La víctima estaba en la zona azul",
			"Ningún sospechoso estaba junto a una estantería",
		] {
			let interpreted = try interpreter.interpret(text: text, context: context)
			rules.append(contentsOf: interpreted.rules)
			generalRules.append(contentsOf: interpreted.generalRules)
		}
		
		// When
		let start = Date()
		let result = PuzzleSolver.solve(context: context, rules: rules, generalRules: generalRules)
		let elapsed = Date().timeIntervalSince(start)
		
		// Then
		#expect(result != .noSolution)
		#expect(elapsed < 0.05, "El solver debe resolver el puzzle de referencia en menos de 50 ms (tardó \(elapsed) s).")
	}
	
	// MARK: - Solver outcomes
	
	@Test("Las reglas contradictorias no deben tener solución")
	func contradictoryRulesReturnNoSolution() {
		// Given
		let context = Self.context(rows: 3, columns: 3, zones: [], suspects: ["A", "B"])
		let rules = [
			GameRule(person: .suspect("A"), target: .person(.suspect("B")), comparison: .equal, relation: .southOf),
			GameRule(person: .suspect("B"), target: .person(.suspect("A")), comparison: .equal, relation: .southOf),
		]
		
		// When
		let result = PuzzleSolver.solve(context: context, rules: rules)
		
		// Then
		#expect(result == .noSolution)
	}
	
	@Test("Reglas insuficientes deben devolver varias celdas de víctima")
	func insufficientRulesReturnMultipleVictimCells() {
		// Given
		let red = ZoneID(index: 0, name: "rojo")
		let context = BoardContext(
			rows: 3,
			columns: 3,
			cells: [
				[
					BoardCell(elements: [], zone: red),
					BoardCell(elements: [], zone: red),
					BoardCell(elements: [], zone: nil),
				],
				[
					BoardCell(elements: [], zone: nil),
					BoardCell(elements: [], zone: nil),
					BoardCell(elements: [], zone: nil),
				],
				[
					BoardCell(elements: [], zone: nil),
					BoardCell(elements: [], zone: nil),
					BoardCell(elements: [], zone: nil),
				],
			],
			zones: [red],
			suspects: ["A"],
		)
		let rules = [
			GameRule(person: .victim, target: .zone(red), comparison: .equal, relation: .inZone),
		]
		
		// When
		let result = PuzzleSolver.solve(context: context, rules: rules)
		
		// Then
		switch result {
		case .multipleVictimCells(let cells):
			#expect(cells == Set([CellKey(row: 0, col: 0), CellKey(row: 0, col: 1)]))
		case .uniqueVictim(let cell, _):
			#expect(cell == CellKey(row: 0, col: 0))
		case .noSolution:
			#expect(Bool(false))
		case .noRules:
			#expect(Bool(false))
		case .tooComplex:
			#expect(Bool(false))
		}
	}

	@Test("El límite de nodos excedido debe devolver tooComplex")
	func nodeLimitExceededReturnsTooComplex() {
		// Given
		let context = Self.context(rows: 2, columns: 2, zones: [], suspects: ["A"])
		let rules = [
			GameRule(person: .suspect("A"), target: .element(.chair), comparison: .equal, relation: .on),
		]
		
		// When
		let result = PuzzleSolver.solve(context: context, rules: rules, nodeLimit: 0)
		
		// Then
		#expect(result == .tooComplex)
	}
	
	@Test("Sin reglas el solver debe devolver noRules")
	func emptyRulesReturnNoRules() {
		// Given
		let context = Self.context(rows: 2, columns: 2, zones: [], suspects: ["A"])
		
		// When
		let result = PuzzleSolver.solve(context: context, rules: [])
		
		// Then
		#expect(result == .noRules)
	}
	
	// MARK: - Rule evaluation
	
	@Test("Una regla de adyacencia debe evaluarse correctamente")
	func personRuleEvaluatesAdjacency() {
		// Given
		let context = BoardContext(
			rows: 2,
			columns: 2,
			cells: [
				[
					BoardCell(elements: [.plant], zone: nil),
					BoardCell(elements: [], zone: nil),
				],
				[
					BoardCell(elements: [], zone: nil),
					BoardCell(elements: [], zone: nil),
				],
			],
			zones: [],
			suspects: ["A"],
		)
		let adjacentRule = GameRule(person: .suspect("A"), target: .element(.plant), comparison: .equal, relation: .adjacentTo)
		let assignment: [RulePerson: CellKey] = [.suspect("A"): CellKey(row: 0, col: 1)]
		
		// When / Then
		#expect(adjacentRule.isSatisfied(by: context, assignment: assignment))
		
		let negatedRule = GameRule(person: .suspect("A"), target: .element(.plant), comparison: .not, relation: .adjacentTo)
		#expect(!negatedRule.isSatisfied(by: context, assignment: assignment))
	}
	
	@Test("Una regla de posición relativa debe evaluarse correctamente")
	func personRuleEvaluatesRelativeRelation() {
		// Given
		let context = Self.context(rows: 3, columns: 3, zones: [], suspects: ["B", "C"])
		let relativeRule = GameRule(person: .suspect("B"), target: .person(.suspect("C")), comparison: .equal, relation: .southOf)
		
		// When / Then
		#expect(relativeRule.isSatisfied(by: context, assignment: [
			.suspect("B"): CellKey(row: 2, col: 0),
			.suspect("C"): CellKey(row: 1, col: 1),
		]))
		#expect(!relativeRule.isSatisfied(by: context, assignment: [
			.suspect("B"): CellKey(row: 0, col: 0),
			.suspect("C"): CellKey(row: 1, col: 1),
		]))
	}
	
	@Test("Las reglas generales deben evaluarse correctamente")
	func generalRulesAreEvaluated() {
		// Given
		let red = ZoneID(index: 0, name: "rojo")
		let context = Self.context(rows: 2, columns: 3, zones: [red], suspects: ["A", "B"])
		
		// Contar dos sospechosos en la zona roja debe satisfacer el conteo.
		let countRule = GeneralRule.countInZone(red, 2, comparison: .equal)
		#expect(RuleEvaluator.isSatisfied([countRule], context: context, assignment: [
			.suspect("A"): CellKey(row: 0, col: 0),
			.suspect("B"): CellKey(row: 0, col: 1),
		]))
		#expect(!RuleEvaluator.isSatisfied([countRule], context: context, assignment: [
			.suspect("A"): CellKey(row: 0, col: 0),
		]))
		
		// La regla de unicidad exige exactamente un ocupante en la silla.
		let uniqueContext = BoardContext(
			rows: 2,
			columns: 1,
			cells: [
				[BoardCell(elements: [.chair], zone: nil)],
				[BoardCell(elements: [], zone: nil)],
			],
			zones: [],
			suspects: ["A", "B"],
		)
		let uniqueRule = GeneralRule.uniqueOn(.chair)
		#expect(RuleEvaluator.isSatisfied([uniqueRule], context: uniqueContext, assignment: [
			.suspect("A"): CellKey(row: 0, col: 0),
			.suspect("B"): CellKey(row: 1, col: 0),
		]))
		#expect(!RuleEvaluator.isSatisfied([uniqueRule], context: uniqueContext, assignment: [
			.suspect("A"): CellKey(row: 0, col: 0),
			.suspect("B"): CellKey(row: 0, col: 0),
		]))
	}
	
	// MARK: - Helpers
	
	/// Builds a board context with the given dimensions, zones and suspects; every cell is empty.
	private static func context(rows: Int, columns: Int, zones: [ZoneID], suspects: [String]) -> BoardContext {
		var cells: [[BoardCell]] = []
		for row in 0..<rows {
			var boardRow: [BoardCell] = []
			for _ in 0..<columns {
				boardRow.append(BoardCell(elements: [], zone: zones.indices.contains(row) ? zones[row] : nil))
			}
			cells.append(boardRow)
		}
		return BoardContext(rows: rows, columns: columns, cells: cells, zones: zones, suspects: suspects)
	}
}
