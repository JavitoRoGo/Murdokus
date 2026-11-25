//
//  RuleInterpreter.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 25/11/2026.
//

import Foundation

/// The outcome of interpreting a set of rule texts.
struct InterpretedRules: Sendable, Equatable, Hashable, Codable {
	
	/// The person-scoped rules that were successfully interpreted.
	let rules: [GameRule]
	
	/// The general rules that were successfully interpreted.
	let generalRules: [GeneralRule]
	
	/// The issues found while interpreting the texts.
	let issues: [RuleParseIssue]
}

/// A problem found while interpreting rule texts.
struct RuleParseIssue: Sendable, Equatable, Hashable, Codable {
	
	/// The kind of problem detected in the text.
	let kind: RuleParseIssueKind
	
	/// A human-readable description of the problem.
	let message: String
}

/// The kinds of problems a rule parser can report.
enum RuleParseIssueKind: Sendable, Equatable, Hashable, Codable {
	
	/// The text contains a phrase that could not be understood.
	case unknownText
	
	/// The text references an element that is not part of the vocabulary.
	case unknownElement
	
	/// The text references a zone that is not part of the palette.
	case unknownZone
	
	/// The text describes an ambiguous rule.
	case ambiguous
	
	/// The text references a suspect that does not exist in the context.
	case invalidSuspect
}

/// An interpreter that converts Spanish rule texts into structured rules.
protocol RuleInterpreter: Sendable {
	
	/// Interprets the given rule text into structured rules.
	///
	/// - Parameters:
	///   - text: The Spanish text describing the rules.
	///   - context: The board context used to resolve zones and suspects.
	/// - Returns: The interpreted rules, general rules and issues.
	/// - Throws: An error when the interpretation cannot be completed.
	func interpret(text: String, context: BoardContext) throws -> InterpretedRules
}
