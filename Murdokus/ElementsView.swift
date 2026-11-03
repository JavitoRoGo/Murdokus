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
			if !engine.showingSuspects {
				Section {
					if engine.roomColors.isEmpty {
						ContentUnavailableView("Elige el número de espacios", systemImage: "paintbrush")
					} else {
						LazyVGrid(columns: columns) {
							ForEach(engine.roomColors, id: \.self) { color in
								RoomColorView(roomColor: color)
							}
						}
					}
				} header: {
					Text("Espacios")
						.font(.headline)
						.padding(.vertical, 10)
				}
				
				if !engine.roomColors.isEmpty {
					Divider()
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
					
					Button() {
						withAnimation {
							engine.activePaintColor = nil
							engine.handleTimer(.start)
							engine.showingSuspects = true
						}
					} label: {
						Text("Comenzar")
							.font(.largeTitle)
					}
					.buttonStyle(.borderedProminent)
				}
			} else {
				LazyVGrid(columns: columns) {
					ForEach(engine.suspects) { suspect in
						SingleElementView(object: suspect)
					}
				}
				Divider()
				HStack {
					SingleElementView(object: MurdokuObject(name: "Casilla bloqueada", element: .xMark))
					SingleElementView(object: MurdokuObject(name: "Víctima", element: .victim))
				}
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
