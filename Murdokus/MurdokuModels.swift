//
//  MurdokuModels.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 26/10/2026.
//

import SwiftUI
import UniformTypeIdentifiers

/// An enumeration of the element types that can appear in a Murdoku grid.
///
/// MurdokuElement describes the kinds of objects that populate the puzzle
/// board, such as pieces, furniture, or blocked cells.
enum MurdokuElement: String, CaseIterable, Identifiable, Codable {

	/// A suspect character that appears in the puzzle.
	case suspect = "Sospechoso"

	/// A victim character that appears in the puzzle.
	case victim = "Víctima"

	/// A blocked cell that cannot contain any element.
	case xMark = "Casilla bloqueada"

	/// A chair that can support other elements stacked on top of it.
	case chair = "Silla"

	/// A table that cannot support other elements stacked on top of it.
	case table = "Mesa"

	/// A rug that can support other elements stacked on top of it.
	case rug = "Alfombra"

	/// A plant that cannot support other elements stacked on top of it.
	case plant = "Planta"

	/// A bed that can support other elements stacked on top of it.
	case bed = "Cama"

	/// A bookshelf that cannot support other elements stacked on top of it.
	case bookshelf = "Estantería"

	/// A television that cannot support other elements stacked on top of it.
	case tv = "TV"
	
	/// A car that can support other elements stacked on top of it.
	case car = "Coche"
	
	/// A window that can support other elements stacked on top of it.
	case window = "Ventana"
	
	/// A cash machine that cannot support other elements stacked on top of it.
	case cash = "Registradora"
	
	/// A rock that cannot support other elements stacked on top of it.
	case rock = "Roca"
	
	/// A statue that cannot support other elements stacked on top of it.
	case statue = "Estatua"
	
	/// A rubble that cannot support other elements stacked on top of it.
	case rubble = "Escombros"
	
	/// A tree that cannot support other elements stacked on top of it.
	case tree = "Árbol"

	/// The identifier of the element, equal to its raw string value.
	var id: Self { self }

	/// Returns the SF Symbols name for the receiver, optionally scoped to a suspect.
	///
	/// The returned symbol name is suitable for rendering the element as an
	/// icon. When the receiver is a suspect, the given suspect identifier is
	/// lowercased and combined with the circle symbol.
	///
	/// - Parameter suspect: The identifier of the suspect used to build the symbol name.
	/// - Returns: The SF Symbols name that represents the element.
	@ViewBuilder
	func icon(for suspect: String = "") -> some View {
		switch self {
		case .suspect: Image(systemName: "\(suspect.lowercased()).circle.fill")
		case .victim: Text("😵")
		case .xMark: Image(systemName: "xmark")
		case .chair: Text("🪑")
		case .table: Text("🟫")
		case .rug: Text("🔲")
		case .plant: Text("🪴")
		case .bed: Text("🛏️")
		case .bookshelf: Text("📚")
		case .tv: Text("📺")
		case .car: Text("🚙")
		case .window: Text("🪟")
		case .cash: Text("💰")
		case .rock: Text("🪨")
		case .statue: Text("🗿")
		case .rubble: Text("🛘")
		case .tree: Text("🌳")
		}
	}

	/// Indicates whether the receiver can have other elements stacked on top of it.
	var canStackOnTop: Bool {
		switch self {
		case .chair, .bed, .rug, .car, .window:
			return true
		default:
			return false
		}
	}

	/// Returns all the elements that can be placed in the grid, excluding suspects and victims.
	static var elements: [MurdokuElement] {
		self.allCases.filter { $0 != .suspect && $0 != .victim }
	}
}

/// A model representing an object that can be placed in a Murdoku grid.
struct MurdokuObject: Identifiable, Codable, Transferable {

	/// The unique identifier of the object, equal to its name.
	var id: String { name }

	/// The name of the object.
	var name: String

	/// The element type that describes the object.
	var element: MurdokuElement

	/// The capital letter associated with the object, if any.
	var capitalLetter: String? = nil

	/// A flag indicating whether the object has been placed in the grid.
	var isPlaced: Bool? = nil

	/// Indicates whether the object participates in the undo history.
	///
	/// Only suspects and X-marks are undoable; other game objects such as
	/// furniture are part of the board state but not of the player's action history.
	var isUndoable: Bool {
		self.element == .suspect || self.element == .xMark
	}

	/// The custom transfer representation used to encode and decode the object.
	static var transferRepresentation: CodableRepresentation<MurdokuObject, JSONEncoder, JSONDecoder> {
		CodableRepresentation(contentType: .murdokuObject)
	}
}

/// A package that represents a Murdoku object together with the position it came from.
struct MurdokuTransferPackage: Codable, Transferable {

	/// The object being transferred.
	let object: MurdokuObject

	/// The row of the source cell.
	let sourceRow: Int

	/// The column of the source cell.
	let sourceCol: Int

	static var transferRepresentation: CodableRepresentation<MurdokuTransferPackage, JSONEncoder, JSONDecoder> {
		CodableRepresentation(contentType: .murdokuObject)
	}
}

/// A key that identifies a position within the game grid.
struct CellKey: Hashable {
	/// The row index of the cell.
	let row: Int
	/// The column index of the cell.
	let col: Int
}

/// A grid cell that holds a collection of placed elements and its color.
struct Cell {
	/// The elements currently placed in the cell.
	var elements: [MurdokuObject] = []

	/// The color associated with the cell.
	var color: Color
}

extension UTType {
	/// The custom uniform type identifier used for Murdoku object transfers.
	static let murdokuObject = UTType("com.murdoku.object")!
}

/// The color snapshot of a grid cell, storing its RGBA components.
struct SavedGameColor: Codable {
	/// The red component, between 0.0 and 1.0.
	var red: Double
	/// The green component, between 0.0 and 1.0.
	var green: Double
	/// The blue component, between 0.0 and 1.0.
	var blue: Double
	/// The opacity component, between 0.0 and 1.0.
	var opacity: Double
}

/// A snapshot of a grid cell: the elements placed in it and its background color.
struct SavedGameCell: Codable {
	/// The elements currently placed in the cell.
	var elements: [MurdokuObject] = []
	/// The color associated with the cell.
	var color: SavedGameColor
}

/// A snapshot of a game board configuration: dimensions, suspects and cell disposition.
struct SavedGameSnapshot: Codable {
	/// The number of rows of the saved board.
	var rows: Int
	/// The number of columns of the saved board.
	var columns: Int
	/// The number of spaces or colors of the saved game board.
	var colors: Int = 0
	/// The number of suspects of the saved board.
	var suspectsNumber: Int
	/// The cells of the saved board, indexed first by row and then by column.
	var cells: [[SavedGameCell]]
}

extension SavedGameSnapshot {
	/// Encodes the snapshot into JSON data.
	static func encode(_ snapshot: SavedGameSnapshot) throws -> Data {
		let encoder = JSONEncoder()
		return try encoder.encode(snapshot)
	}

	/// Decodes a snapshot from its JSON data representation.
	static func decode(from data: Data) throws -> SavedGameSnapshot {
		let decoder = JSONDecoder()
		return try decoder.decode(SavedGameSnapshot.self, from: data)
	}
}
