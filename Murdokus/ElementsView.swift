//
//  ElementsView.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 19/10/2026.
//

import SwiftUI

struct ElementsView: View {
	@Environment(GridEngine.self) private var engine
	@Environment(SavedGamesStore.self) private var savedGamesStore

	@State private var showingSaveSheet = false
	@State private var saveGameName = ""

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
					
					VStack(spacing: 12) {
						Button("Guardar partida") {
							if let savedGameID = engine.savedGameID,
							   let game = savedGamesStore.games.first(where: { $0.id == savedGameID }) {
								saveGameName = game.name
							} else {
								saveGameName = ""
							}
							showingSaveSheet = true
						}
						.buttonStyle(.bordered)
						
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
				}
			} else {
				Text("Pulsa sobre un sospechoso para marcar su ubicación posible.\nArrástralo para ponerlo en su ubicación definitiva.")
					.multilineTextAlignment(.center)
					.font(.subheadline)
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
		.sheet(isPresented: $showingSaveSheet) {
			SaveGameSheet(saveGameName: $saveGameName, solveTime: nil)
		}
	}
}

#Preview {
    ElementsView()
        .environment(GridEngine())
        .environment(SavedGamesStore.preview)
}
