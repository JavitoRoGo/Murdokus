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
				.fill(isSelected ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(.ultraThinMaterial))
		}
        .opacity(canDrag ? 1.0 : 0.3)
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .onTapGesture {
            guard object.element == .suspect else { return }
            guard object.isPlaced != true else { return }
            engine.handleIntent(.selectSuspect(capitalLetter: object.capitalLetter ?? ""))
        }
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
	
	/// Whether this element is the suspect currently selected for candidate placement.
	private var isSelected: Bool {
		object.element == .suspect && engine.selectedSuspect == object.capitalLetter
	}

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
