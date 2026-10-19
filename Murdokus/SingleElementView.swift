//
//  SingleElementView.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 19/10/2026.
//

import SwiftUI

struct SingleElementView: View {
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
    }
}

#Preview {
	SingleElementView(object: MurdokuObject(name: "char", element: .chair))
}
