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
		ScrollView {
			if engine.showingSuspects {
				Text("Pulsa sobre un sospechoso para marcar su ubicación posible.\nArrástralo para ponerlo en su ubicación definitiva.")
					.multilineTextAlignment(.center)
					.font(.subheadline)
				LazyVGrid(columns: [GridItem(.adaptive(minimum: 130))]) {
					ForEach(engine.suspects) { suspect in
						SingleElementView(object: suspect)
					}
				}
				Divider()
				HStack {
					SingleElementView(object: MurdokuObject(name: "Casilla bloqueada", element: .xMark))
					SingleElementView(object: MurdokuObject(name: "Víctima", element: .victim))
				}
			} else {
				switch engine.setupStep {
				case .colors:
					ColorsStepView()
				case .elements:
					ElementsStepView()
				case .instructions:
					InstructionsStepView(
						onBack: { engine.setupStep = .elements },
						onSave: { saveCurrentGame() }
					)
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

	/// Saves the current game disposition, presenting the save sheet.
	private func saveCurrentGame() {
		if let savedGameID = engine.savedGameID,
		   let game = savedGamesStore.games.first(where: { $0.id == savedGameID }) {
			saveGameName = game.name
		} else {
			saveGameName = ""
		}
		showingSaveSheet = true
	}
}

#Preview {
    ElementsView()
        .environment(GridEngine())
        .environment(SavedGamesStore.preview)
}
