//
//  MurdokuObjectProvider.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 30/10/2026.
//

import SwiftUI
import UniformTypeIdentifiers

/// A custom provider that enables dragging and dropping Murdoku objects through `NSItemProvider`.
///
/// `MurdokuObjectProvider` adapts a `MurdokuObject` into a transferable payload by wrapping it
/// inside a `MurdokuTransferPackage`, including the source position, so it can be moved between
/// views or exported as data.
final class MurdokuObjectProvider: NSObject, NSItemProviderWriting {
	/// The Murdoku object being transferred.
	let object: MurdokuObject
	/// The row of the source cell the object belongs to.
	let row: Int
	/// The column of the source cell the object belongs to.
	let col: Int
	/// The type identifier used for Murdoku object transfers.
	static let typeIdentifier = "com.murdoku.object"
	
	/// Initializes a new object provider with the given object and its source position.
	///
	/// - Parameters:
	///   - object: The Murdoku object to be transferred.
	///   - row: The row of the source cell.
	///   - col: The column of the source cell.
	init(object: MurdokuObject, row: Int, col: Int) {
		self.object = object
		self.row = row
		self.col = col
		super.init()
	}
	
	/// Returns the uniform type identifiers the provider is able to write.
	static var writableTypeIdentifiersForItemProvider: [String] {
		[typeIdentifier]
	}
	
	/// Loads the data of the wrapped transfer package for the specified type.
	///
	/// The object is wrapped in a `MurdokuTransferPackage` along with its source position,
	/// then encoded into JSON data for the completion handler.
	///
	/// - Parameters:
	///   - typeIdentifier: The uniform type identifier for which the data is requested.
	///   - completionHandler: The completion handler that receives the encoded data or an error.
	/// - Returns: `nil`, as the asynchronous completion is handled by the completion handler.
	func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
		let encoder = JSONEncoder()
		do {
			// Envolvemos el objeto en el paquete de transferencia que incluye la posición
			let package = MurdokuTransferPackage(object: object, sourceRow: row, sourceCol: col)
			let data = try encoder.encode(package)
			completionHandler(data, nil)
		} catch {
			completionHandler(nil, error)
		}
		return nil
	}
}
