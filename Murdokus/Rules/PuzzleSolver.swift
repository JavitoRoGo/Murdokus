//
//  PuzzleSolver.swift
//  Murdokus
//

import Foundation

/// The outcome of solving the rules of a puzzle against a board context.
enum SolverResult: Sendable, Equatable, Hashable {
	
	/// The puzzle rules admit a unique placement of the victim.
	case uniqueVictim(CellKey, [String: CellKey])
	
	/// The puzzle rules admit more than one possible placement of the victim.
	case multipleVictimCells(Set<CellKey>)
	
	/// The puzzle rules are contradictory, so no placement is valid.
	case noSolution
	
	/// The puzzle does not provide rules to solve.
	case noRules
	
	/// The solver exceeded the computational limits before finishing the search.
	case tooComplex
}

/// A deterministic constraint solver that finds the victim placement of a puzzle.
///
/// The solver backtracks over the suspects and the victim of the puzzle, enforcing
/// both the relational constraints of the structured rules and the global constraint
/// of one person per row and per column of the board. The search combines the minimum
/// remaining values heuristic with forward checking over the candidate cells.
struct PuzzleSolver {
	
	/// The maximum number of search nodes explored before the solver gives up.
	static let defaultNodeLimit = 1_000_000
	
	/// The maximum time the solver may spend searching before giving up.
	static let defaultTimeLimit: TimeInterval = 5.0
	
	/// Runs the solver against the given board context and rules.
	///
	/// - Parameters:
	///   - context: The board context holding the zones and occupiable cells of the puzzle.
	///   - rules: The person-scoped rules of the puzzle.
	///   - generalRules: The general rules of the puzzle.
	///   - nodeLimit: The maximum number of search nodes explored before giving up.
	///   - timeLimit: The maximum time spent searching before giving up.
	///   - isCancelled: A closure that reports whether the search was cancelled.
	/// - Returns: The outcome of the solving process.
	static func solve(
		context: BoardContext,
		rules: [GameRule],
		generalRules: [GeneralRule] = [],
		nodeLimit: Int = defaultNodeLimit,
		timeLimit: TimeInterval = defaultTimeLimit,
		isCancelled: @escaping () -> Bool = { false }
	) -> SolverResult {
		guard !rules.isEmpty || !generalRules.isEmpty else { return .noRules }
		let solver = BacktrackingSolver(context: context, rules: rules, generalRules: generalRules)
		solver.nodeLimit = nodeLimit
		solver.timeLimit = timeLimit
		solver.isCancelled = isCancelled
		return solver.run()
	}
}

// MARK: - Backtracking solver

/// The outcome of a single step of the backtracking search.
private enum SearchOutcome {
	
	/// The search must keep exploring the remaining candidates.
	case keepSearching
	
	/// The puzzle admits a unique victim; the associated values are its cell and placements.
	case uniqueVictim(CellKey, [String: CellKey])
	
	/// The puzzle admits more than one victim cell.
	case multipleVictimCells(Set<CellKey>)
	
	/// The puzzle rules are contradictory, so no placement is valid.
	case noSolution
	
	/// The solver exceeded the computational limits before finishing the search.
	case tooComplex
}

/// The internal deterministic backtracking solver that explores the placements of the puzzle persons.
private final class BacktrackingSolver {
	
	/// The board context used to resolve zones and occupiable cells.
	let context: BoardContext
	
	/// The person-scoped rules of the puzzle.
	let rules: [GameRule]
	
	/// The general rules of the puzzle.
	let generalRules: [GeneralRule]
	
	/// The maximum number of search nodes explored before giving up.
	var nodeLimit: Int
	
	/// The maximum time the solver may spend searching before giving up.
	var timeLimit: TimeInterval
	
	/// A closure that reports whether the search was cancelled.
	var isCancelled: () -> Bool
	
	/// The persons involved in the puzzle: the suspects of the context and the victim.
	private(set) var persons: [RulePerson]
	
	/// The current assignment of persons to cells.
	private var assignment: [RulePerson: CellKey] = [:]
	
	/// The remaining candidate cells of every person.
	private var domains: [RulePerson: Set<CellKey>] = [:]
	
	/// The date from which the search time is measured.
	private var searchStartDate = Date()
	
	/// The number of search nodes explored so far.
	private var nodeCount = 0
	
	/// The victim cell of the first solution found, if any.
	private var firstVictimCell: CellKey?
	
	/// The placements of the suspects of the first solution found, if any.
	private var firstPlacements: [String: CellKey] = [:]
	
	/// Creates a solver for the given board context and rules.
	///
	/// - Parameters:
	///   - context: The board context used to resolve zones and occupiable cells.
	///   - rules: The person-scoped rules of the puzzle.
	///   - generalRules: The general rules of the puzzle.
	init(context: BoardContext, rules: [GameRule], generalRules: [GeneralRule]) {
		self.context = context
		self.rules = rules
		self.generalRules = generalRules
		self.nodeLimit = PuzzleSolver.defaultNodeLimit
		self.timeLimit = PuzzleSolver.defaultTimeLimit
		self.isCancelled = { false }
		self.persons = Self.persons(context: context)
	}
	
	/// Runs the search and translates the outcome into a `SolverResult`.
	func run() -> SolverResult {
		domains = Self.domains(context: context, persons: persons)
		assignment = [:]
		firstVictimCell = nil
		firstPlacements = [:]
		switch search() {
		case .keepSearching:
			// The whole search space was explored after the first solution was found.
			if let first = firstVictimCell { return .uniqueVictim(first, firstPlacements) }
			return .noSolution
		case .uniqueVictim(let victimCell, let placements):
			return .uniqueVictim(victimCell, placements)
		case .multipleVictimCells(let cells):
			return .multipleVictimCells(cells)
		case .noSolution:
			return .noSolution
		case .tooComplex:
			return .tooComplex
		}
	}
	
	/// Performs the backtracking search over the domains of the puzzle persons.
	private func search() -> SearchOutcome {
		if isCancelled() { return .tooComplex }
		nodeCount += 1
		if nodeCount > nodeLimit { return .tooComplex }
		if Date().timeIntervalSince(searchStartDate) > timeLimit { return .tooComplex }
		
		// A complete assignment was reached: validate it and report the outcome.
		if assignment.count == persons.count {
			return evaluateFullAssignment()
		}
		
		// Minimum remaining values heuristic: choose the most constrained unassigned person.
		var chosenPerson: RulePerson?
		var chosenDomain: Set<CellKey>?
		for person in persons {
			guard assignment[person] == nil else { continue }
			let domain = domains[person] ?? []
			if domain.isEmpty { return .noSolution }
			if let current = chosenDomain, domain.count >= current.count { continue }
			chosenPerson = person
			chosenDomain = domain
		}
		guard let person = chosenPerson, let domain = chosenDomain else { return .noSolution }
		
		for cell in domain.sorted(by: { ($0.row, $0.col) < ($1.row, $1.col) }) {
			guard isConsistent(person: person, cell: cell, assignment: assignment, rules: rules) else { continue }
			
			let previousAssignment = assignment
			let previousDomains = domains
			var nextAssignment = assignment
			nextAssignment[person] = cell
			var nextDomains = domains
			nextDomains[person] = [cell]
			for other in persons where other != person && nextAssignment[other] == nil {
				var remaining = nextDomains[other] ?? []
				remaining = remaining.filter { $0.row != cell.row && $0.col != cell.col }
				nextDomains[other] = remaining
			}
			assignment = nextAssignment
			domains = nextDomains
			let outcome = search()
			assignment = previousAssignment
			domains = previousDomains
			switch outcome {
			case .keepSearching:
				continue
			case .uniqueVictim:
				// The subtree was exhausted after its first solution, so the parent must
				// keep exploring the remaining candidates looking for further solutions.
				continue
			case .multipleVictimCells(let cells):
				return .multipleVictimCells(cells)
			case .noSolution:
				continue
			case .tooComplex:
				return .tooComplex
			}
		}
		if let first = firstVictimCell { return .uniqueVictim(first, firstPlacements) }
		return .noSolution
	}
	
	/// Validates the complete assignment and decides the outcome for the reached solution.
	private func evaluateFullAssignment() -> SearchOutcome {
		guard isValidFullAssignment() else { return .noSolution }
		guard let victimCell = assignment[RulePerson.victim] else { return .noSolution }
		if let first = firstVictimCell {
			if victimCell != first { return .multipleVictimCells([first, victimCell]) }
			// The victim cell repeats, so the search keeps looking for another solution.
			return .keepSearching
		}
		firstVictimCell = victimCell
		firstPlacements = Self.placements(of: victimCell, assignment: assignment, persons: persons)
		return .keepSearching
	}
	
	/// The persons involved in the puzzle: the suspects of the context and the victim.
	private static func persons(context: BoardContext) -> [RulePerson] {
		var persons: [RulePerson] = []
		for letter in context.suspects {
			persons.append(RulePerson.suspect(letter))
		}
		persons.append(RulePerson.victim)
		return persons
	}
	
	/// Builds the candidate cells of every person: the occupiable cells of the board.
	private static func domains(context: BoardContext, persons: [RulePerson]) -> [RulePerson: Set<CellKey>] {
		var domains: [RulePerson: Set<CellKey>] = [:]
		for person in persons {
			var cells: Set<CellKey> = []
			for row in 0..<context.rows {
				for col in 0..<context.columns {
					let cell = CellKey(row: row, col: col)
					let element: MurdokuElement = person.isVictim ? .victim : .suspect
					if context.cells[row][col].isOccupiableByPerson(element) {
						cells.insert(cell)
					}
				}
			}
			domains[person] = cells
		}
		return domains
	}
	
	/// The placements of the suspects of the given solution.
	private static func placements(of victimCell: CellKey, assignment: [RulePerson: CellKey], persons: [RulePerson]) -> [String: CellKey] {
		var placements: [String: CellKey] = [:]
		for person in persons where !person.isVictim {
			if let capitalLetter = person.capitalLetter, let cell = assignment[person] {
				placements[capitalLetter] = cell
			}
		}
		return placements
	}
	
	/// Checks whether placing a person in a cell keeps the assignment consistent with the rules.
	private func isConsistent(
		person: RulePerson,
		cell: CellKey,
		assignment: [RulePerson: CellKey],
		rules: [GameRule]
	) -> Bool {
		// Global constraint: one person per row and per column of the board.
		for (assignedPerson, assignedCell) in assignment where assignedPerson != person {
			if assignedCell.row == cell.row || assignedCell.col == cell.col { return false }
		}
		var nextAssignment = assignment
		nextAssignment[person] = cell
		for rule in rules {
			let involved = RuleEvaluator.involvedPersons(of: rule)
			// Relative rules wait until the referenced person is placed as well.
			guard involved.allSatisfy({ nextAssignment[$0] != nil }) else { continue }
			if !rule.isSatisfied(by: context, assignment: nextAssignment) { return false }
		}
		return true
	}
	
	/// Validates the complete assignment against the person and general rules.
	private func isValidFullAssignment() -> Bool {
		for rule in rules {
			if !rule.isSatisfied(by: context, assignment: assignment) { return false }
		}
		return RuleEvaluator.isSatisfied(generalRules, context: context, assignment: assignment)
	}
}
