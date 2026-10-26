//
//  ElementsView.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 19/10/2026.
//

import SwiftUI

struct ElementsView: View {
	@Environment(GridEngine.self) private var engine
	
    var body: some View {
		let columns = [GridItem(.adaptive(minimum: 130))]
		
		ScrollView {
			Section {
				LazyVGrid(columns: columns) {
					ForEach(engine.objects) { object in
						SingleElementView(object: object)
					}
				}
			} header: {
				Text("Elementos")
					.font(.headline)
			}
			
			Divider()
			
			Section {
				if engine.suspects.isEmpty {
					ContentUnavailableView("Elige el número de sospechosos", systemImage: "person.circle.fill")
				} else {
					LazyVGrid(columns: columns) {
						ForEach(engine.suspects) { object in
							SingleElementView(object: object)
						}
					}
				}
			} header: {
				Text("Sospechosos")
					.font(.headline)
					.padding(.vertical, 10)
			}
		}
		.frame(minWidth: 300)
		.padding()
		.background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    ElementsView()
		.environment(GridEngine())
}
