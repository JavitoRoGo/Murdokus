import SwiftUI
import UniformTypeIdentifiers

/// Un contenedor que permite transportar un MurdokuObject a través del sistema de Drag & Drop
/// cumpliendo con el protocolo NSItemProviderWriting para evitar inicializadores deprecados.
final class MurdokuObjectProvider: NSObject, NSItemProviderWriting {
	let object: MurdokuObject
	let row: Int
	let col: Int
	static let typeIdentifier = "com.murdoku.object"
	
	init(object: MurdokuObject, row: Int, col: Int) {
		self.object = object
		self.row = row
		self.col = col
		super.init()
	}
	
	static var writableTypeIdentifiersForItemProvider: [String] {
		[typeIdentifier]
	}
	
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
