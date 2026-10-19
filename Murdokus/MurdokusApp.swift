//
//  MurdokusApp.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 18/10/2026.
//

import SwiftUI

@main
struct MurdokusApp: App {
	@State private var engine = GridEngine(rows: 5, columns: 5, numOfSuspects: 3)
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environment(engine)
				.frame(minWidth: 800, minHeight: 600)
		}
		.windowStyle(.hiddenTitleBar)
	}
}
