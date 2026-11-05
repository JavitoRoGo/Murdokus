//
//  SavedGamesView.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 05/11/2026.
//

import SwiftUI

struct SavedGamesView: View {
	@Environment(GridEngine.self) private var engine
	@Environment(SavedGamesStore.self) private var savedGamesStore

	var body: some View {
		List {
			ForEach(savedGamesStore.games) { game in
				HStack(spacing: 8) {
					Button {
						load(game)
					} label: {
						VStack(alignment: .leading, spacing: 2) {
							Text(game.name)
								.font(.headline)
							if let solveTime = game.solveTime {
								Text("Resuelta en \(Self.formattedTime(solveTime))")
									.font(.subheadline)
									.foregroundStyle(.secondary)
							}
						}
					}
					.buttonStyle(.plain)
				}
				.swipeActions {
					Button("Borrar", role: .destructive) {
						try? savedGamesStore.delete(game)
					}
				}
			}
		}
		.listStyle(.inset)
		.navigationTitle("Partidas guardadas")
	}
	
	/// The presentation state of the rename sheet.
//	@State private var isRenameSheetPresented: Bool = false

	/// Loads the board disposition of the given saved game into the engine.
	private func load(_ game: SavedGame) {
		guard let data = game.boardData else { return }
		guard let snapshot = try? SavedGameSnapshot.decode(from: data) else { return }
		engine.loadSavedGame(snapshot, solveTime: game.solveTime)
		engine.savedGameID = game.id
	}

	/// Formats a solve time in seconds as a `mm:ss` string.
	private static func formattedTime(_ seconds: TimeInterval) -> String {
		let totalSeconds = Int(seconds.rounded())
		let minutes = totalSeconds / 60
		let seconds = totalSeconds % 60
		return String(format: "%02d:%02d", minutes, seconds)
	}
}

#Preview {
	SavedGamesView()
		.environment(GridEngine())
		.environment(SavedGamesStore.preview)
}
