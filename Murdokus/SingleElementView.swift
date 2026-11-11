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
	
	private var icon: some View {
		object.element.icon(for: object.capitalLetter ?? "")
	}
	
    var body: some View {
		HStack {
			Text(object.name)
			Spacer()
			icon
				.font(object.element == .suspect ? .largeTitle : .title)
				.padding(10)
				.background {
					Circle()
						.fill(.ultraThickMaterial)
				}
				.onDrag {
					guard canDrag else { return NSItemProvider() }
					engine.draggingObject = object
					return NSItemProvider(object: MurdokuObjectProvider(object: object, row: -1, col: -1))
				} preview: {
					icon
						.font(.largeTitle)
						.frame(width: 50, height: 50)
						.foregroundColor(.black.opacity(0.5))
						.opacity(canDrag ? 1.0 : 0.3)
						.padding(10)
						.background(Circle().fill(.ultraThinMaterial))
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
