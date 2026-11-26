//
//  GameRule.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 25/11/2026.
//

import Foundation
import SwiftUI

/// The person that a puzzle rule refers to.
///
/// A person is either a specific suspect identified by its capital letter
/// or the victim of the puzzle.
struct RulePerson: Sendable, Equatable, Hashable, Codable {
	
	/// The capital letter of the suspect the rule refers to, or `nil` for the victim.
	let capitalLetter: String?
	
	/// Indicates whether the person is the victim of the puzzle.
	let isVictim: Bool
	
	/// Creates a person from a suspect capital letter or from the victim.
	///
	/// - Parameters:
	///   - capitalLetter: The capital letter of the suspect, or `nil` for the victim.
	///   - isVictim: Indicates whether the person is the victim of the puzzle.
	init(capitalLetter: String? = nil, isVictim: Bool = false) {
		self.capitalLetter = capitalLetter
		self.isVictim = isVictim
	}
	
	/// The victim of the puzzle.
	static var victim: RulePerson {
		RulePerson(capitalLetter: nil, isVictim: true)
	}
	
	/// A suspect identified by its capital letter.
	///
	/// - Parameter capitalLetter: The capital letter of the suspect, such as `"A"`.
	static func suspect(_ capitalLetter: String) -> RulePerson {
		RulePerson(capitalLetter: capitalLetter, isVictim: false)
	}
}

/// The subject of a person rule.
enum RuleTarget: Sendable, Equatable, Hashable, Codable {
	
	/// The element the person must relate to.
	case element(MurdokuElement)
	
	/// The zone the person must relate to.
	case zone(ZoneID)
	
	/// The person the subject refers to, used for relative rules such as `"B al sur de C"`.
	case person(RulePerson)
}

/// The relation between a person and the subject of the rule.
enum RuleRelation: Sendable, Equatable, Hashable, Codable {
	
	/// The person must be placed next to the subject element.
	case adjacentTo
	
	/// The person must be placed on the subject element.
	case on
	
	/// The person must be placed in the subject zone.
	case inZone
	
	/// The person must be placed south of the subject person.
	case southOf
	
	/// The person must be placed north of the subject person.
	case northOf
	
	/// The person must be placed east of the subject person.
	case eastOf
	
	/// The person must be placed west of the subject person.
	case westOf
	
	/// The person must be placed northeast of the subject person.
	case northeastOf
	
	/// The person must be placed northwest of the subject person.
	case northwestOf
	
	/// The person must be placed southeast of the subject person.
	case southeastOf
	
	/// The person must be placed southwest of the subject person.
	case southwestOf
}

/// The comparison between a person placement and its subject.
enum RuleComparison: Sendable, Equatable, Hashable, Codable {
	
	/// The relation must hold.
	case equal
	
	/// The relation must hold at least once.
	case atLeast
	
	/// The relation must hold at most once.
	case atMost
	
	/// The relation must not hold.
	case not
}

/// A rule that relates a person to a subject within the puzzle.
struct GameRule: Sendable, Equatable, Hashable, Codable {
	
	/// The person the rule applies to.
	let person: RulePerson
	
	/// The element or zone the person must relate to, or the referenced person.
	let target: RuleTarget
	
	/// The comparison between the placement and the target.
	let comparison: RuleComparison
	
	/// The relation between the person and the target, when the rule is relational.
	let relation: RuleRelation?
	
	/// Creates a rule that relates a person to a subject.
	///
	/// - Parameters:
	///   - person: The person the rule applies to.
	///   - target: The element or zone the person must relate to, or the referenced person.
	///   - comparison: The comparison between the placement and the target.
	///   - relation: The relation between the person and the target, when the rule is relational.
	init(person: RulePerson, target: RuleTarget, comparison: RuleComparison, relation: RuleRelation? = nil) {
		self.person = person
		self.target = target
		self.comparison = comparison
		self.relation = relation
	}

	/// Returns whether the rule is satisfied by the given assignment of persons to cells.
	///
	/// - Parameters:
	///   - context: The board context used to resolve elements, zones and relations.
	///   - assignment: The assignment of persons to cells, which may be partial.
	/// - Returns: `true` when the rule holds for the assignment; while the involved persons
	///   are not placed yet, the rule holds vacuously.
	func isSatisfied(by context: BoardContext, assignment: [RulePerson: CellKey]) -> Bool {
		RuleEvaluator.isSatisfied(self, context: context, assignment: assignment)
	}
}

/// A general rule that is not scoped to a single person.
enum GeneralRule: Sendable, Equatable, Hashable, Codable {
	
	/// No suspect was placed next to any of the given elements.
	case noneOfElements([MurdokuElement])
	
	/// The number of suspects placed in a zone satisfies the comparison.
	case countInZone(ZoneID, Int, comparison: RuleComparison)
	
	/// All suspects were placed in distinct zones.
	case allDistinctZones
	
	/// Exactly one suspect was placed on the given element.
	case uniqueOn(MurdokuElement)
}

/// The identifier of a zone (room) of the board.
struct ZoneID: Sendable, Equatable, Hashable, Codable {
	
	/// The zero-based index of the zone within the room palette.
	let index: Int
	
	/// The Spanish display name of the zone, such as `"rojo"`.
	let name: String
	
	/// Creates a zone from its palette index and display name.
	///
	/// - Parameters:
	///   - index: The zero-based index of the zone within the room palette.
	///   - name: The Spanish display name of the zone, such as `"rojo"`.
	init(index: Int, name: String) {
		self.index = index
		self.name = name
	}
}

extension ZoneID {
	
	/// The palette of zones, ordered by palette index.
	static var palette: [ZoneID] {
		[
			ZoneID(index: 0, name: "rojo"),
			ZoneID(index: 1, name: "azul"),
			ZoneID(index: 2, name: "amarillo"),
			ZoneID(index: 3, name: "verde"),
			ZoneID(index: 4, name: "naranja"),
			ZoneID(index: 5, name: "morado"),
			ZoneID(index: 6, name: "marrón"),
			ZoneID(index: 7, name: "rosa"),
			ZoneID(index: 8, name: "menta"),
			ZoneID(index: 9, name: "índigo"),
		]
	}
	
	/// The base color of each zone in the palette, in palette order.
	static var paletteColors: [Color] {
		[
			Color.red, Color.blue, Color.yellow, Color.green,
			Color.orange, Color.purple, Color.brown, Color.pink,
			Color.mint, Color.indigo,
		].map { $0.opacity(0.3) }
	}
}
