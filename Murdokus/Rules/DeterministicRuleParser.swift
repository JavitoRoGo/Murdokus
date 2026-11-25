//
//  DeterministicRuleParser.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 25/11/2026.
//

import Foundation

/// A parser that interprets Spanish rule texts into structured rules.
///
/// The parser is deterministic: the same input text and board context always
/// produce the same structured rules and diagnostics. It never invents rules:
/// any phrase it cannot map to the supported grammar is reported as an issue
/// instead of being guessed.
struct DeterministicRuleParser: RuleInterpreter {
	
	/// The pattern of a relative rule sentence, such as `"B al sur de C"`.
	/// It also supports combined directions such as `"B al norte y a la derecha de C"`.
	private static let relativeRulePattern = "estaba (?:al|en la) (norte|sur|este|oeste|noreste|noroeste|sureste|suroeste|derecha|izquierda)(?: y (?:a la|al|en la) (norte|sur|este|oeste|noreste|noroeste|sureste|suroeste|derecha|izquierda))? de ([a-z]+)"
	
	/// Interprets a set of rule texts into structured rules.
	///
	/// - Parameter text: The Spanish text describing the rules.
	/// - Parameter context: The board context used to resolve zones and suspects.
	/// - Returns: The interpreted rules, general rules and issues.
	func interpret(text: String, context: BoardContext) throws -> InterpretedRules {
		var rules: [GameRule] = []
		var generalRules: [GeneralRule] = []
		var issues: [RuleParseIssue] = []
		
		for rawSentence in text.components(separatedBy: ".") {
			let sentence = normalize(rawSentence)
			guard !sentence.isEmpty else { continue }
			
			if Self.isGeneralSentence(in: sentence) {
				generalRules.append(contentsOf: Self.generalRules(in: sentence, issues: &issues))
			} else if let rule = Self.personRule(in: sentence, context: context, issues: &issues) {
				rules.append(rule)
				if Self.isUnique(in: sentence), let element = Self.element(in: sentence, issues: &issues) {
					generalRules.append(.uniqueOn(element))
				}
			}
		}
		
		return InterpretedRules(rules: rules, generalRules: generalRules, issues: issues)
	}
	
	// MARK: - General sentences
	
	/// Indicates whether the sentence expresses a general rule instead of a
	/// rule scoped to a single person.
	private static func isGeneralSentence(in sentence: String) -> Bool {
		sentence.contains("ningun") || sentence.contains("ninguna") || sentence.contains("habia") || sentence.contains("todos")
	}
	
	/// Builds the general rules of a sentence.
	private static func generalRules(in sentence: String, issues: inout [RuleParseIssue]) -> [GeneralRule] {
		if let count = Self.countRule(in: sentence, issues: &issues) {
			return [count]
		}
		if sentence.contains("ningun") || sentence.contains("ninguna") {
			if let element = Self.element(in: sentence, issues: &issues) {
				return [.noneOfElements([element])]
			}
			return []
		}
		if sentence.contains("todos") {
			return [.allDistinctZones]
		}
		return []
	}
	
	/// Builds the count general rule of the sentence, if present.
	private static func countRule(in sentence: String, issues: inout [RuleParseIssue]) -> GeneralRule? {
		guard let regex = try? NSRegularExpression(pattern: "habia exactamente ([a-z]+) personas en la zona ([a-z]+)") else { return nil }
		let range = NSRange(location: 0, length: sentence.utf16.count)
		guard let match = regex.firstMatch(in: sentence, range: range) else { return nil }
		let number = Self.count(from: (sentence as NSString).substring(with: match.range(at: 1)))
		let zoneName = (sentence as NSString).substring(with: match.range(at: 2))
		guard let zone = Self.zone(byName: zoneName, issues: &issues) else { return nil }
		guard let number else { return nil }
		return .countInZone(zone, number, comparison: .equal)
	}
	
	// MARK: - Person rules
	
	/// Builds the rule of the person described by the sentence, if any.
	private static func personRule(in sentence: String, context: BoardContext, issues: inout [RuleParseIssue]) -> GameRule? {
		guard let person = Self.person(in: sentence, context: context, issues: &issues) else { return nil }
		
		if let zone = Self.zone(in: sentence, issues: &issues) {
			return GameRule(person: person, target: .zone(zone), comparison: Self.negated(in: sentence) ? .not : .equal, relation: .inZone)
		}
		
		if let element = Self.element(in: sentence, issues: &issues) {
			let relation: RuleRelation = Self.isOn(in: sentence) ? .on : .adjacentTo
			return GameRule(person: person, target: .element(element), comparison: Self.negated(in: sentence) ? .not : .equal, relation: relation)
		}
		
		if let referenced = Self.referencedPerson(in: sentence, context: context, issues: &issues) {
			let relation: RuleRelation = Self.relativeRelation(in: sentence) ?? .southOf
			return GameRule(person: person, target: .person(referenced), comparison: Self.negated(in: sentence) ? .not : .equal, relation: relation)
		}
		
		issues.append(RuleParseIssue(kind: .unknownText, message: "No se pudo interpretar la regla: \(sentence)"))
		return nil
	}
	
	/// Resolves the person the sentence refers to.
	private static func person(in sentence: String, context: BoardContext, issues: inout [RuleParseIssue]) -> RulePerson? {
		if sentence.contains("victima") { return .victim }
		if let letter = Self.suspectLetter(in: sentence) {
			if context.suspects.contains(letter) { return .suspect(letter) }
			issues.append(RuleParseIssue(kind: .invalidSuspect, message: "El sospechoso \(letter) no existe en el contexto."))
			return nil
		}
		issues.append(RuleParseIssue(kind: .unknownText, message: "No se pudo identificar la persona en la regla: \(sentence)"))
		return nil
	}
	
	/// Extracts the suspect letter the sentence refers to.
	private static func suspectLetter(in sentence: String) -> String? {
		guard let regex = try? NSRegularExpression(pattern: "\\b([a-z])\\b") else { return nil }
		let range = NSRange(location: 0, length: sentence.utf16.count)
		guard let match = regex.firstMatch(in: sentence, range: range) else { return nil }
		return String((sentence as NSString).substring(with: match.range(at: 1))).uppercased()
	}
	
	/// Resolves the zone referenced by the sentence.
	private static func zone(in sentence: String, issues: inout [RuleParseIssue]) -> ZoneID? {
		guard let regex = try? NSRegularExpression(pattern: "en la zona ([a-z]+)") else { return nil }
		let range = NSRange(location: 0, length: sentence.utf16.count)
		guard let match = regex.firstMatch(in: sentence, range: range) else { return nil }
		return Self.zone(byName: (sentence as NSString).substring(with: match.range(at: 1)), issues: &issues)
	}
	
	/// Resolves the element referenced by the sentence.
	private static func element(in sentence: String, issues: inout [RuleParseIssue]) -> MurdokuElement? {
		let patterns = [
			"sobre (?:una|el|la) ([a-z]+)",
			"encima de (?:una|el|la) ([a-z]+)",
			"sentada en (?:una|el|la) ([a-z]+)",
			"(?:junto a|al lado de) (?:una|el|la) ([a-z]+)",
		]
		for pattern in patterns {
			guard let regex = try? NSRegularExpression(pattern: pattern) else { continue }
			let range = NSRange(location: 0, length: sentence.utf16.count)
			if let match = regex.firstMatch(in: sentence, range: range) {
				return Self.element(byName: (sentence as NSString).substring(with: match.range(at: 1)), issues: &issues)
			}
		}
		return nil
	}
	
	/// Resolves the referenced person of a relative rule such as `"B al sur de C"`.
	private static func referencedPerson(in sentence: String, context: BoardContext, issues: inout [RuleParseIssue]) -> RulePerson? {
		guard let regex = try? NSRegularExpression(pattern: Self.relativeRulePattern) else { return nil }
		let range = NSRange(location: 0, length: sentence.utf16.count)
		guard let match = regex.firstMatch(in: sentence, range: range) else { return nil }
		guard match.range(at: 3).location != NSNotFound else { return nil }
		let letter = String((sentence as NSString).substring(with: match.range(at: 3))).uppercased()
		guard context.suspects.contains(letter) else {
			issues.append(RuleParseIssue(kind: .invalidSuspect, message: "El sospechoso \(letter) no existe en el contexto."))
			return nil
		}
		return .suspect(letter)
	}
	
	/// Extracts the relative relation of a sentence, if present.
	private static func relativeRelation(in sentence: String) -> RuleRelation? {
		guard let regex = try? NSRegularExpression(pattern: Self.relativeRulePattern) else { return nil }
		let range = NSRange(location: 0, length: sentence.utf16.count)
		guard let match = regex.firstMatch(in: sentence, range: range) else { return nil }
		let firstDirection = (sentence as NSString).substring(with: match.range(at: 1))
		guard let firstRelation = Self.relation(for: firstDirection) else { return nil }
		if match.range(at: 2).location == NSNotFound {
			return firstRelation
		}
		let secondDirection = (sentence as NSString).substring(with: match.range(at: 2))
		guard let secondRelation = Self.relation(for: secondDirection) else { return nil }
		return Self.combinedRelation(of: firstRelation, with: secondRelation)
	}
	
	/// Maps a normalized Spanish direction to its relative relation.
	private static func relation(for direction: String) -> RuleRelation? {
		switch direction {
		case "norte": return .northOf
		case "sur": return .southOf
		case "este", "derecha": return .eastOf
		case "oeste", "izquierda": return .westOf
		case "noreste": return .northeastOf
		case "noroeste": return .northwestOf
		case "sureste": return .southeastOf
		case "suroeste": return .southwestOf
		default: return nil
		}
	}
	
	/// Combines two relative directions into the resulting relation.
	private static func combinedRelation(of first: RuleRelation, with second: RuleRelation) -> RuleRelation? {
		switch (first, second) {
		case (.northOf, .eastOf), (.eastOf, .northOf):
			return .northeastOf
		case (.northOf, .westOf), (.westOf, .northOf):
			return .northwestOf
		case (.southOf, .eastOf), (.eastOf, .southOf):
			return .southeastOf
		case (.southOf, .westOf), (.westOf, .southOf):
			return .southwestOf
		case (.northOf, .northOf), (.southOf, .southOf), (.eastOf, .eastOf), (.westOf, .westOf):
			return first
		default:
			return nil
		}
	}
	
	/// Indicates whether the person was placed on an element.
	private static func isOn(in sentence: String) -> Bool {
		sentence.contains("sobre") || sentence.contains("encima de") || sentence.contains("sentada en")
	}
	
	/// Indicates whether the sentence expresses a negation.
	private static func negated(in sentence: String) -> Bool {
		sentence.contains(" no ") || sentence.hasPrefix("no ")
	}
	
	/// Indicates whether the sentence expresses a uniqueness constraint.
	private static func isUnique(in sentence: String) -> Bool {
		sentence.contains("unica") || sentence.contains("unicas")
	}
	
	// MARK: - Vocabulary resolution
	
	/// Resolves the zone identifier from its normalized name.
	private static func zone(byName name: String, issues: inout [RuleParseIssue]) -> ZoneID? {
		let zones: [String: ZoneID] = [
			"rojo": ZoneID(index: 0, name: "rojo"),
			"roja": ZoneID(index: 0, name: "rojo"),
			"azul": ZoneID(index: 1, name: "azul"),
			"amarillo": ZoneID(index: 2, name: "amarillo"),
			"amarilla": ZoneID(index: 2, name: "amarillo"),
			"verde": ZoneID(index: 3, name: "verde"),
			"naranja": ZoneID(index: 4, name: "naranja"),
			"morado": ZoneID(index: 5, name: "morado"),
			"marron": ZoneID(index: 6, name: "marrón"),
			"rosa": ZoneID(index: 7, name: "rosa"),
			"menta": ZoneID(index: 8, name: "menta"),
			"indigo": ZoneID(index: 9, name: "indigo"),
		]
		return zones[name]
	}
	
	/// Resolves the element from its normalized name.
	private static func element(byName name: String, issues: inout [RuleParseIssue]) -> MurdokuElement? {
		switch name {
		case "planta": return .plant
		case "silla": return .chair
		case "alfombra": return .rug
		case "estantaria", "estanteria": return .bookshelf
		case "mesa": return .table
		case "cama": return .bed
		case "television": return .tv
		case "ventana": return .window
		case "coche": return .car
		case "caja": return .box
		case "regalo": return .gift
		case "roca": return .rock
		case "estatua": return .statue
		case "arbol": return .tree
		case "escombros": return .rubble
		case "registradora": return .cash
		default:
			issues.append(RuleParseIssue(kind: .unknownElement, message: "Elemento desconocido: \(name)"))
			return nil
		}
	}
	
	/// Converts a Spanish number word into its integer value.
	private static func count(from word: String) -> Int? {
		switch word {
		case "uno": return 1
		case "dos": return 2
		case "tres": return 3
		case "cuatro": return 4
		case "cinco": return 5
		case "seis": return 6
		default: return nil
		}
	}
}

// MARK: - Normalization

/// Normalizes a rule sentence: lowercase, accents removed, trimmed and collapsed.
internal func normalize(_ text: String) -> String {
	var value = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
	value = value.replacing("á", with: "a")
		.replacing("é", with: "e")
		.replacing("í", with: "i")
		.replacing("ó", with: "o")
		.replacing("ú", with: "u")
		.replacing("ü", with: "u")
		.replacing("ñ", with: "n")
	value = value.replacingOccurrences(of: "  ", with: " ").trimmingCharacters(in: .whitespacesAndNewlines)
	return value
}
