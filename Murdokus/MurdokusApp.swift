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
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.frame(minWidth: 1000, minHeight: 700)
				.environment(engine)
				.colorScheme(.light)
		}
		.windowStyle(.hiddenTitleBar)
	}
}
