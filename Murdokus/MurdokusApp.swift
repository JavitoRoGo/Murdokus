//
//  MurdokusApp.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 18/10/2026.
//

import SwiftUI
import SwiftData

@main
struct MurdokusApp: App {
	private let modelContainer: ModelContainer
	
	@State private var engine = GridEngine()
	@State private var savedGamesStore: SavedGamesStore
	
	init() {
		let schema = Schema([SavedGame.self])
		let modelConfiguration = ModelConfiguration(schema: schema)
		do {
			modelContainer = try ModelContainer(for: schema, configurations: modelConfiguration)
			savedGamesStore = SavedGamesStore(modelContext: modelContainer.mainContext)
		} catch {
			fatalError("Failed to create the ModelContainer for the saved games.")
		}
	}

	var body: some Scene {
		return WindowGroup {
			ContentView()
				.frame(minWidth: 1000, minHeight: 700)
				.environment(engine)
				.environment(savedGamesStore)
				.colorScheme(.light)
		}
		.windowStyle(.hiddenTitleBar)
	}
}
