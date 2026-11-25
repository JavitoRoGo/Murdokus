//  RuleParserTests.swift
//  Murdokus

import Testing
import Foundation
import SwiftUI

@testable import Murdokus

@Suite("Pruebas del Parser de Reglas")
struct RuleParserTests {

	@Test("Una regla de adyacencia debe interpretarse desde el texto del sospechoso")
	func adjacencyRuleFromSuspectText() throws {
		// Given
		let parser = DeterministicRuleParser()
		let context = BoardContext(rows: 0, columns: 0, cells: [], zones: [], suspects: ["A", "B", "C", "D", "E"])

		// When
		let result = try parser.interpret(text: "A estaba junto a una planta", context: context)

		// Then
		#expect(result.rules == [GameRule(person: .suspect("A"), target: .element(.plant), comparison: .equal, relation: .adjacentTo)], "regla de adyacencia")
		#expect(result.issues.isEmpty, "sin issues de adyacencia")
		#expect(result.generalRules.isEmpty, "sin generales de adyacencia")
	}

	@Test("Una regla negada debe marcar la comparación como no aplicable")
	func negatedAdjacencyRuleUsesNotComparison() throws {
		// Given
		let parser = DeterministicRuleParser()
		let context = BoardContext(rows: 0, columns: 0, cells: [], zones: [], suspects: ["A", "B", "C", "D", "E"])

		// When
		let result = try parser.interpret(text: "A no estaba junto a una estantería", context: context)

		// Then
		#expect(result.rules.count == 1, "cantidad de reglas")
		#expect(result.rules.first?.person == .suspect("A"), "persona")
		#expect(result.rules.first?.target == .element(.bookshelf), "sujeto elemento")
		#expect(result.rules.first?.comparison == .not, "comparacion")
		#expect(result.rules.first?.relation == .adjacentTo, "relacion")
		#expect(result.issues.isEmpty, "issues del parser")
	}

	@Test("Una regla de posición relativa debe resolverse sobre el sospechoso referenciado")
	func relativeRuleResolvesReferencedSuspect() throws {
		// Given
		let parser = DeterministicRuleParser()
		let context = BoardContext(rows: 0, columns: 0, cells: [], zones: [], suspects: ["A", "B", "C"])

		// When
		let result = try parser.interpret(text: "B estaba al sur de C", context: context)

		// Then
		#expect(result.rules == [GameRule(person: .suspect("B"), target: .person(.suspect("C")), comparison: .equal, relation: .southOf)], "regla relativa")
		#expect(result.issues.isEmpty, "sin issues de relativa")
	}

	@Test("Una regla relativa diagonal debe interpretarse desde el texto del sospechoso")
	func diagonalRelativeRuleFromSuspectText() throws {
		// Given
		let parser = DeterministicRuleParser()
		let context = BoardContext(rows: 0, columns: 0, cells: [], zones: [], suspects: ["A", "B", "C"])

		// When
		let result = try parser.interpret(text: "B estaba al noreste de C", context: context)

		// Then
		#expect(result.rules == [GameRule(person: .suspect("B"), target: .person(.suspect("C")), comparison: .equal, relation: .northeastOf)], "regla relativa diagonal")
		#expect(result.issues.isEmpty, "sin issues de relativa diagonal")
	}

	@Test("Una regla relativa con direcciones combinadas debe interpretarse como la dirección resultante")
	func combinedRelativeRuleUsesResultantDirection() throws {
		// Given
		let parser = DeterministicRuleParser()
		let context = BoardContext(rows: 0, columns: 0, cells: [], zones: [], suspects: ["A", "B", "C"])

		// When
		let result = try parser.interpret(text: "B estaba al norte y a la derecha de C", context: context)

		// Then
		#expect(result.rules == [GameRule(person: .suspect("B"), target: .person(.suspect("C")), comparison: .equal, relation: .northeastOf)], "regla relativa combinada")
		#expect(result.issues.isEmpty, "sin issues de relativa combinada")
	}

	@Test("Una regla relativa combinada debe interpretarse como la dirección resultante")
	func combinedRelativeRuleUsesResultantDirectionInOppositeSense() throws {
		// Given
		let parser = DeterministicRuleParser()
		let context = BoardContext(rows: 0, columns: 0, cells: [], zones: [], suspects: ["A", "B", "C"])

		// When
		let result = try parser.interpret(text: "B estaba al sur y a la izquierda de C", context: context)

		// Then
		#expect(result.rules == [GameRule(person: .suspect("B"), target: .person(.suspect("C")), comparison: .equal, relation: .southwestOf)], "regla relativa combinada opuesta")
		#expect(result.issues.isEmpty, "sin issues de relativa combinada opuesta")
	}

	@Test("Una regla de apilamiento debe interpretarse como una relación de sobre")
	func stackingRuleUsesOnRelation() throws {
		// Given
		let parser = DeterministicRuleParser()
		let context = BoardContext(rows: 0, columns: 0, cells: [], zones: [], suspects: ["A", "B", "C", "D", "E"])

		// When
		let result = try parser.interpret(text: "C estaba sobre una alfombra", context: context)

		// Then
		#expect(result.rules == [GameRule(person: .suspect("C"), target: .element(.rug), comparison: .equal, relation: .on)], "regla de sobre")
		#expect(result.issues.isEmpty, "sin issues de sobre")
	}

	@Test("Una regla de única persona debe generar la regla y la general única")
	func uniquePersonRuleGeneratesPersonAndGeneralRules() throws {
		// Given
		let parser = DeterministicRuleParser()
		let context = BoardContext(rows: 0, columns: 0, cells: [], zones: [], suspects: ["A", "B", "C", "D", "E"])

		// When
		let result = try parser.interpret(text: "D era la unica persona sentada en una silla", context: context)

		// Then
		#expect(result.rules == [GameRule(person: .suspect("D"), target: .element(.chair), comparison: .equal, relation: .on)], "regla de unica")
		#expect(result.generalRules == [.uniqueOn(.chair)], "general de unica")
		#expect(result.issues.isEmpty, "sin issues de unica")
	}

	@Test("Una regla de zona debe interpretarse con su relación de zona")
	func zoneRuleFromSuspectText() throws {
		// Given
		let parser = DeterministicRuleParser()
		let context = BoardContext(rows: 0, columns: 0, cells: [], zones: [], suspects: ["A", "B", "C", "D", "E"])

		// When
		let result = try parser.interpret(text: "E estaba en la zona roja", context: context)

		// Then
		#expect(result.rules == [GameRule(person: .suspect("E"), target: .zone(ZoneID(index: 0, name: "rojo")), comparison: .equal, relation: .inZone)], "regla de zona")
		#expect(result.issues.isEmpty, "sin issues de zona")
	}

	@Test("Una regla de zona negada debe marcar la comparación como no aplicable")
	func negatedZoneRuleUsesNotComparison() throws {
		// Given
		let parser = DeterministicRuleParser()
		let context = BoardContext(rows: 0, columns: 0, cells: [], zones: [], suspects: ["A", "B", "C", "D", "E"])

		// When
		let result = try parser.interpret(text: "E no estaba en la zona azul", context: context)

		// Then
		#expect(result.rules == [GameRule(person: .suspect("E"), target: .zone(ZoneID(index: 1, name: "azul")), comparison: .not, relation: .inZone)], "regla de zona negada")
		#expect(result.issues.isEmpty, "sin issues de zona negada")
	}

	@Test("Una regla sobre la víctima debe construirse con la persona víctima")
	func victimRuleFromText() throws {
		// Given
		let parser = DeterministicRuleParser()
		let context = BoardContext(rows: 0, columns: 0, cells: [], zones: [], suspects: ["A", "B", "C", "D", "E"])

		// When
		let result = try parser.interpret(text: "La victima estaba en la zona azul", context: context)

		// Then
		#expect(result.rules == [GameRule(person: .victim, target: .zone(ZoneID(index: 1, name: "azul")), comparison: .equal, relation: .inZone)], "regla de victima")
		#expect(result.issues.isEmpty, "sin issues de victima")
	}

	@Test("Una regla con mayúsculas y acentos debe normalizarse correctamente")
	func normalizedVictimZoneRuleUsesEqualComparison() throws {
		// Given
		let parser = DeterministicRuleParser()
		let context = BoardContext(rows: 0, columns: 0, cells: [], zones: [], suspects: ["A", "B", "C", "D", "E"])

		// When
		let result = try parser.interpret(text: "LA VÍCTIMA ESTABA EN LA ZONA AZUL", context: context)

		// Then
		#expect(result.rules == [GameRule(person: .victim, target: .zone(ZoneID(index: 1, name: "azul")), comparison: .equal, relation: .inZone)], "regla normalizada")
		#expect(result.issues.isEmpty, "sin issues de regla normalizada")
	}

	@Test("La regla de conteo general debe interpretarse desde el texto")
	func generalCountRuleFromText() throws {
		// Given
		let parser = DeterministicRuleParser()
		let context = BoardContext(rows: 0, columns: 0, cells: [], zones: [], suspects: ["A", "B", "C", "D", "E"])

		// When
		let result = try parser.interpret(text: "Habia exactamente dos personas en la zona roja", context: context)

		// Then
		#expect(result.generalRules == [.countInZone(ZoneID(index: 0, name: "rojo"), 2, comparison: .equal)], "general de conteo")
		#expect(result.rules.isEmpty, "sin reglas de conteo")
		#expect(result.issues.isEmpty, "sin issues de conteo")
	}

	@Test("La regla de sospechosos no colocados debe interpretarse como regla general")
	func generalNoneOfRuleFromText() throws {
		// Given
		let parser = DeterministicRuleParser()
		let context = BoardContext(rows: 0, columns: 0, cells: [], zones: [], suspects: ["A", "B", "C", "D", "E"])

		// When
		let result = try parser.interpret(text: "Ningun sospechoso estaba junto a una ventana", context: context)

		// Then
		#expect(result.generalRules == [.noneOfElements([.window])], "general de ningun")
		#expect(result.rules.isEmpty, "sin reglas de ningun")
		#expect(result.issues.isEmpty, "sin issues de ningun")
	}

	@Test("La regla de zonas distintas debe interpretarse como regla general")
	func generalAllDistinctZonesRuleFromText() throws {
		// Given
		let parser = DeterministicRuleParser()
		let context = BoardContext(rows: 0, columns: 0, cells: [], zones: [], suspects: ["A", "B", "C", "D", "E"])

		// When
		let result = try parser.interpret(text: "Todos los sospechosos estaban en zonas distintas", context: context)

		// Then
		#expect(result.generalRules == [.allDistinctZones], "general de todas")
		#expect(result.rules.isEmpty, "sin reglas de todas")
		#expect(result.issues.isEmpty, "sin issues de todas")
	}

	@Test("Un texto no reconocido debe reportar un issue y no generar reglas")
	func unknownTextReportsIssue() throws {
		// Given
		let parser = DeterministicRuleParser()
		let context = BoardContext(rows: 0, columns: 0, cells: [], zones: [], suspects: ["A", "B", "C", "D", "E"])

		// When
		let result = try parser.interpret(text: "La fiesta fue divertida", context: context)

		// Then
		#expect(result.rules.isEmpty, "reglas vacias")
		#expect(result.issues.contains { $0.kind == .unknownText }, "issue de texto")
	}

	@Test("Una letra de sospechoso inexistente debe reportar un issue de sospechoso")
	func invalidSuspectLetterReportsIssue() throws {
		// Given
		let parser = DeterministicRuleParser()
		let context = BoardContext(rows: 0, columns: 0, cells: [], zones: [], suspects: ["A"])

		// When
		let result = try parser.interpret(text: "Z estaba junto a una planta", context: context)

		// Then
		#expect(result.rules.isEmpty, "reglas vacias 2")
		#expect(result.issues.contains { $0.kind == .invalidSuspect }, "issue de sospechoso")
	}
}
