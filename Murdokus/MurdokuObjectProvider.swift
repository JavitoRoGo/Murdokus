import Foundation
import UniformTypeIdentifiers

/// Un contenedor que permite transportar un MurdokuObject a través del sistema de Drag & Drop
/// cumpliendo con el protocolo NSItemProviderWriting para evitar inicializadores deprecados.
final class MurdokuObjectProvider: NSObject, NSItemProviderWriting {
	let object: MurdokuObject
	
	init(object: MurdokuObject) {
		self.object = object
		super.init()
	}
	
	/// Indica al sistema qué tipos de datos puede entregar este proveedor.
	static var writableTypeIdentifiersForItemProvider: [String] {
		[UTType.murdokuObject.identifier]
	}
	
	/// Provee los datos codificados cuando el receptor lo solicita.
	func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
		let encoder = JSONEncoder()
		do {
			let data = try encoder.encode(object)
			completionHandler(data, nil)
		} catch {
			completionHandler(nil, error)
		}
		return nil
	}
}
