//
//  TimerView.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 19/10/2026.
//

import SwiftUI

struct TimerView: View {
	@Environment(GridEngine.self) private var engine

	var body: some View {
		VStack(spacing: 16) {
			TimelineView(.periodic(from: .now, by: 1)) { _ in
				Text(Self.formattedElapsedSeconds(engine.elapsedSeconds))
					.font(Font.system(size: 34).monospaced())
			}
		}
	}

	static func formattedElapsedSeconds(_ seconds: TimeInterval) -> String {
		let totalSeconds = Int(seconds.rounded())
		let minutes = totalSeconds / 60
		let seconds = totalSeconds % 60
		return String(format: "%02d:%02d", minutes, seconds)
	}
}

#Preview {
	TimerView()
		.environment(GridEngine())
}
