//
//  RuleEvaluator.swift
//  Murdokus
//

import Foundation

/// The evaluator that decides whether the rules of a puzzle hold for a board assignment.
///
/// The evaluator is the single source of truth for turning a structured rule and a
/// persons-to-cells assignment into a boolean decision. The solver (F2) and the victim
/// verification flow (F5) reuse it, so both always share the same rule semantics.
struct RuleEvaluator {
	
	/// The persons involved in a puzzle: the suspects of the context plus the victim.
	///
	/// - Parameter context: The board context holding the suspects of the puzzle.
	/// - Returns: The ordered list of persons that participate in the puzzle.
	static func puzzlePersons(context: BoardContext) -> [RulePerson] {
		var persons: [RulePerson] = []
		for letter in context.suspects {
			persons.append(RulePerson.suspect(letter))
		}
		persons.append(RulePerson.victim)
		return persons
	}
	
	/// Returns whether the comparison holds for the given satisfaction flag.
	///
	/// - Parameters:
	///   - comparison: The comparison between the satisfaction of the relation and the expected value.
	///   - holds: The satisfaction flag of the evaluated relation or count.
	/// - Returns: `true` when the comparison holds; otherwise, `false`.
	static func comparisonHolds(comparison: RuleComparison, holds: Bool) -> Bool {
		switch comparison {
		case .equal:
			return holds
		case .atLeast:
			return holds
		case .atMost:
			return holds
		case .not:
			return !holds
		}
	}
	
	/// Returns whether a person rule is satisfied by the given assignment of persons to cells.
	///
	/// Rules whose involved persons are not placed yet in the assignment hold vacuously,
	/// which allows the evaluator to be reused while the search is still partial.
	///
	/// - Parameters:
	///   - rule: The person-scoped rule to evaluate.
	///   - context: The board context used to resolve elements, zones and relations.
	///   - assignment: The assignment of persons to cells.
	/// - Returns: `true` when the rule holds for the assignment.
	static func isSatisfied(_ rule: GameRule, context: BoardContext, assignment: [RulePerson: CellKey]) -> Bool {
		guard let personCell = assignment[rule.person] else { return true }
		guard let holds = Self.relationHolds(rule: rule, context: context, personCell: personCell, assignment: assignment) else {
			return true
		}
		return Self.comparisonHolds(comparison: rule.comparison, holds: holds)
	}
	
	/// Returns whether all the general rules of the puzzle are satisfied by the assignment.
	///
	/// - Parameters:
	///   - generalRules: The general rules of the puzzle.
	///   - context: The board context used to resolve elements, zones and assignments.
	///   - assignment: The assignment of persons to cells.
	/// - Returns: `true` when every general rule holds for the assignment.
	static func isSatisfied(_ generalRules: [GeneralRule], context: BoardContext, assignment: [RulePerson: CellKey]) -> Bool {
		let persons = Self.puzzlePersons(context: context)
		for rule in generalRules {
			switch rule {
			case .uniqueOn(let element):
				let occupants = Self.personsOn(element, context: context, assignment: assignment, persons: persons)
				guard occupants == 1 else { return false }
			case .countInZone(let zone, let number, let comparison):
				let count = Self.suspectsInZone(zone, context: context, assignment: assignment, persons: persons)
				let holds: Bool
				switch comparison {
				case .equal:
					holds = count == number
				case .atLeast:
					holds = count >= number
				case .atMost:
					holds = count <= number
				case .not:
					holds = count != number
				}
				if !Self.comparisonHolds(comparison: comparison, holds: holds) { return false }
			case .noneOfElements(let elements):
				for person in persons where !person.isVictim {
					if let cell = assignment[person], Self.suspectIsAdjacent(to: elements, cell: cell, context: context) {
						return false
					}
				}
			case .allDistinctZones:
				var zones: Set<ZoneID> = []
				var distinct = true
				for person in persons where !person.isVictim {
					if let cell = assignment[person], let zone = context.cells[cell.row][cell.col].zone {
						if !zones.insert(zone).inserted {
							distinct = false
							break
						}
					}
				}
				if !distinct { return false }
			}
		}
		return true
	}
	
	/// The persons involved in a rule: the rule person plus the referenced person of relative rules.
	///
	/// - Parameter rule: The rule to resolve the involved persons of.
	/// - Returns: The list of persons that participate in the rule.
	static func involvedPersons(of rule: GameRule) -> [RulePerson] {
		var involved: [RulePerson] = [rule.person]
		if case .person(let referenced) = rule.target {
			involved.append(referenced)
		}
		return involved
	}
	
	// MARK: - Relations
	
	/// Evaluates the relation between the person of the rule and its subject.
	///
	/// - Parameters:
	///   - rule: The person-scoped rule being evaluated.
	///   - context: The board context used to resolve elements and zones.
	///   - personCell: The cell where the rule person was placed.
	///   - assignment: The assignment of persons to cells.
	/// - Returns: The satisfaction flag of the relation, or `nil` when it cannot be decided yet.
	private static func relationHolds(rule: GameRule, context: BoardContext, personCell: CellKey, assignment: [RulePerson: CellKey]) -> Bool? {
		let relation = rule.relation ?? Self.defaultRelation(for: rule)
		switch relation {
		case .adjacentTo, .on, .inZone:
			switch rule.target {
			case .element(let element):
				if relation == .on {
					return context.cells[personCell.row][personCell.col].elements.contains(element) && element.canStackOnTop
				}
				return isAdjacent(to: element, at: personCell, context: context)
			case .zone(let zone):
				return context.cells[personCell.row][personCell.col].zone == zone
			case .person:
				return nil
			}
		case .southOf, .northOf, .eastOf, .westOf, .northeastOf, .northwestOf, .southeastOf, .southwestOf:
			guard case .person(let referenced) = rule.target else { return nil }
			guard let referencedCell = assignment[referenced] else { return nil }
			return relativeRelationHolds(relation, personCell: personCell, referencedCell: referencedCell)
		}
	}
	
	/// The relation that a person rule assumes when none was explicitly provided.
	///
	/// - Parameter rule: The person-scoped rule being evaluated.
	/// - Returns: The default relation derived from the subject of the rule.
	private static func defaultRelation(for rule: GameRule) -> RuleRelation {
		switch rule.target {
		case .element:
			return .on
		case .zone:
			return .inZone
		case .person:
			return .southOf
		}
	}
	
	/// Indicates whether the person placed in the cell is positioned in the given relative direction.
	///
	/// - Parameters:
	///   - relation: The relative relation between the person and the referenced person.
	///   - personCell: The cell where the person was placed.
	///   - referencedCell: The cell where the referenced person was placed.
	/// - Returns: `true` when the person is placed in the given direction; otherwise, `false`.
	private static func relativeRelationHolds(_ relation: RuleRelation, personCell: CellKey, referencedCell: CellKey) -> Bool {
		switch relation {
		case .southOf:
			return personCell.row > referencedCell.row
		case .northOf:
			return personCell.row < referencedCell.row
		case .eastOf:
			return personCell.col > referencedCell.col
		case .westOf:
			return personCell.col < referencedCell.col
		case .northeastOf:
			return personCell.row < referencedCell.row && personCell.col > referencedCell.col
		case .northwestOf:
			return personCell.row < referencedCell.row && personCell.col < referencedCell.col
		case .southeastOf:
			return personCell.row > referencedCell.row && personCell.col > referencedCell.col
		case .southwestOf:
			return personCell.row > referencedCell.row && personCell.col < referencedCell.col
		case .adjacentTo, .on, .inZone:
			return false
		}
	}
	
	/// Indicates whether the given element is placed adjacent to the cell of a person.
	///
	/// - Parameters:
	///   - element: The element that must be adjacent to the person.
	///   - cell: The cell where the person was placed.
	///   - context: The board context with the elements of the board.
	/// - Returns: `true` when the element is orthogonally adjacent to the cell; otherwise, `false`.
	private static func isAdjacent(to element: MurdokuElement, at cell: CellKey, context: BoardContext) -> Bool {
		let directions: [(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]
		for direction in directions {
			let row = cell.row + direction.0
			let col = cell.col + direction.1
			if row < 0 || row >= context.rows || col < 0 || col >= context.columns { continue }
			if context.cells[row][col].elements.contains(element) { return true }
		}
		return false
	}
	
	/// Counts the persons placed on the given element of the assignment.
	///
	/// - Parameters:
	///   - element: The element that must be stacked by the persons.
	///   - context: The board context used to resolve the elements of the cells.
	///   - assignment: The assignment of persons to cells.
	///   - persons: The persons involved in the puzzle.
	/// - Returns: The number of persons placed on the element.
	private static func personsOn(_ element: MurdokuElement, context: BoardContext, assignment: [RulePerson: CellKey], persons: [RulePerson]) -> Int {
		var occupants = 0
		for person in persons {
			if let cell = assignment[person], context.cells[cell.row][cell.col].elements.contains(element) && element.canStackOnTop {
				occupants += 1
			}
		}
		return occupants
	}
	
	/// Counts the suspects placed in the given zone of the assignment.
	///
	/// - Parameters:
	///   - zone: The zone that must be counted.
	///   - context: The board context used to resolve the zones of the cells.
	///   - assignment: The assignment of persons to cells.
	///   - persons: The persons involved in the puzzle.
	/// - Returns: The number of suspects placed in the zone.
	private static func suspectsInZone(_ zone: ZoneID, context: BoardContext, assignment: [RulePerson: CellKey], persons: [RulePerson]) -> Int {
		var count = 0
		for person in persons where !person.isVictim {
			if let cell = assignment[person], context.cells[cell.row][cell.col].zone == zone {
				count += 1
			}
		}
		return count
	}
	
	/// Indicates whether any suspect of the assignment is adjacent to the given elements.
	///
	/// - Parameters:
	///   - elements: The elements that must not be adjacent to the suspects.
	///   - cell: The cell where the suspect was placed.
	///   - context: The board context used to resolve the elements of the board.
	/// - Returns: `true` when at least one suspect is adjacent to the elements; otherwise, `false`.
	private static func suspectIsAdjacent(to elements: [MurdokuElement], cell: CellKey, context: BoardContext) -> Bool {
		let directions: [(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]
		for element in elements {
			for direction in directions {
				let row = cell.row + direction.0
				let col = cell.col + direction.1
				if row < 0 || row >= context.rows || col < 0 || col >= context.columns { continue }
				if context.cells[row][col].elements.contains(element) { return true }
			}
		}
		return false
	}
}
