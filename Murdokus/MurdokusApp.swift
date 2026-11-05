//
//  MurdokusApp.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 18/10/2026.
//

import SwiftUI

@main
struct MurdokusApp: App {
	@State private var engine = GridEngine()
	@State private var savedGamesStore: SavedGamesStore = SavedGamesStore()

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
