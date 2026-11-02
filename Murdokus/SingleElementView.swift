//
//  SingleElementView.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 19/10/2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct SingleElementView: View {
	@Environment(GridEngine.self) private var engine
	
	let object: MurdokuObject
	
    var body: some View {
		HStack {
			Text(object.name)
			Spacer()
			Image(systemName: object.element.icon(for: object.capitalLetter ?? ""))
				.font(object.element == .suspect ? .largeTitle : .title2)
				.padding(10)
				.background {
					Circle()
						.fill(.ultraThickMaterial)
				}
		}
		.frame(width: 120)
		.padding(10)
		.background {
			Capsule()
				.fill(.ultraThinMaterial)
		}
        .opacity(canDrag ? 1.0 : 0.3)
        .onDrag {
			guard canDrag else { return NSItemProvider() }
			engine.draggingObject = object
			return NSItemProvider(object: MurdokuObjectProvider(object: object, row: -1, col: -1))
		} preview: {
			Image(systemName: object.element.icon(for: object.capitalLetter ?? ""))
				.resizable()
				.frame(width: 75, height: 75)
				.foregroundColor(.black.opacity(0.5))
				.opacity(canDrag ? 1.0 : 0.3)
				.padding(10)
				.background(Circle().fill(.ultraThinMaterial))
		}
    }
	
	/// Determina si el elemento puede arrastrarse desde el panel.
	/// Los sospechosos ya colocados y la victima (mientras no se hayan colocado todos los sospechosos) estan desactivados.
	var canDrag: Bool {
		switch object.element {
		case .victim:
			return engine.allSuspectsPlaced
		case .suspect:
			return engine.suspects.first { $0.capitalLetter == object.capitalLetter }?.isPlaced != true
		default:
			return true
		}
	}
}

#Preview {
	SingleElementView(object: MurdokuObject(name: "char", element: .chair))
}
