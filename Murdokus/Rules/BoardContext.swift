//
//  BoardContext.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 25/11/2026.
//

import SwiftUI

/// The objective view of the board state used to evaluate puzzle rules.
struct BoardContext: Sendable, Equatable {

	/// The number of rows of the board.
	let rows: Int

	/// The number of columns of the board.
	let columns: Int

	/// The cells of the board, indexed first by row and then by column.
	let cells: [[BoardCell]]

	/// The zones present in the board.
	let zones: [ZoneID]

	/// The capital letters of the suspects involved in the puzzle.
	let suspects: [String]
}

/// A board cell together with the elements it holds and its zone.
struct BoardCell: Sendable, Equatable {

	/// The elements placed in the cell.
	let elements: [MurdokuElement]

	/// The zone the cell belongs to, if painted.
	let zone: ZoneID?

	/// Returns whether a person may be placed in the cell.
	///
	/// A cell is occupiable by a person when it is empty or when it contains a
	/// single furniture element that supports stacking.
	///
	/// - Parameter element: The element of the person to be placed, such as a suspect or the victim.
	/// - Returns: `true` if the person may be placed in the cell; otherwise, `false`.
	func isOccupiableByPerson(_ element: MurdokuElement) -> Bool {
		guard !elements.contains(.xMark) else { return false }
		guard !elements.isEmpty else { return true }
		guard elements.count == 1, elements[0].canStackOnTop else { return false }
		return true
	}
}

/// Builds the board context used by rules, solvers and verifiers.
struct BoardContextBuilder {

	/// Builds the board context of a game session from its engine state.
	///
	/// Suspects, victims and X-marks are ignored, as they are handled by the
	/// rules and the player actions instead of the objective board state.
	///
	/// - Parameter engine: The grid engine holding the current board state.
	/// - Returns: The board context used to evaluate rules.
	static func context(from engine: GridEngine) -> BoardContext {
		var zones: [ZoneID] = []
		var cells: [[BoardCell]] = []

		for row in 0..<engine.rows {
			var rowCells: [BoardCell] = []
			for col in 0..<engine.columns {
				let elements: [MurdokuElement] = engine.cells[row][col].elements.compactMap { object in
					switch object.element {
					case .suspect, .victim, .xMark:
						return nil
					default:
						return object.element
					}
				}
				let zone = zoneID(for: engine.cells[row][col].color)
				if let zone, !zones.contains(zone) { zones.append(zone) }
				rowCells.append(BoardCell(elements: elements, zone: zone))
			}
			cells.append(rowCells)
		}

		return BoardContext(
			rows: engine.rows,
			columns: engine.columns,
			cells: cells,
			zones: zones,
			suspects: engine.suspects.compactMap { $0.capitalLetter }
		)
	}

	/// Resolves the zone of a cell from its color.
	///
	/// - Parameter color: The color of the cell.
	/// - Returns: The matching zone identifier, or `nil` when the cell is not painted.
	private static func zoneID(for color: Color) -> ZoneID? {
		let components = ColorHelper.decomposeColor(color)
		for (zone, paletteColor) in zip(ZoneID.palette, ZoneID.paletteColors) {
			let paletteComponents = ColorHelper.decomposeColor(paletteColor)
			let isSameZone = abs(components.red - paletteComponents.red) < 0.1
				&& abs(components.green - paletteComponents.green) < 0.1
				&& abs(components.blue - paletteComponents.blue) < 0.1
			if isSameZone { return zone }
		}
		return nil
	}
}
