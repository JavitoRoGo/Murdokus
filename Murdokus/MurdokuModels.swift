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

	/// A table that can support other elements stacked on top of it.
	case table = "Mesa"

	/// A rug that can support other elements stacked on top of it.
	case rug = "Alfombra"

	/// A plant that can support other elements stacked on top of it.
	case plant = "Planta"

	/// A bed that can support other elements stacked on top of it.
	case bed = "Cama"

	/// A bookshelf that can support other elements stacked on top of it.
	case bookshelf = "Estantería"

	/// A television that can support other elements stacked on top of it.
	case tv = "TV"

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
	func icon(for suspect: String = "") -> String {
		switch self {
		case .suspect: "\(suspect.lowercased()).circle.fill"
		case .victim: "person.fill.xmark"
		case .xMark: "xmark"
		case .chair: "chair.lounge"
		case .table: "table.furniture"
		case .rug: "light.panel"
		case .plant: "camera.macro"
		case .bed: "bed.double.fill"
		case .bookshelf: "books.vertical"
		case .tv: "tv"
		}
	}

	/// Indicates whether the receiver can have other elements stacked on top of it.
	var canStackOnTop: Bool {
		switch self {
		case .chair, .bed, .rug:
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
