//
//  RoomColorView.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 26/10/2026.
//

import SwiftUI

struct RoomColorView: View {
	@Environment(GridEngine.self) private var engine
	
	let roomColor: Color
	
	var body: some View {
		HStack {
			Text("Espacio")
			Spacer()
			Circle()
				.fill(roomColor)
				.frame(height: 50)
		}
		.frame(width: 120)
		.padding(10)
		.background {
			Capsule()
				.fill(.ultraThinMaterial)
		}
		.onDrag {
			let provider = MurdokuColorProvider(color: roomColor)
			return NSItemProvider(object: provider)
		} preview: {
			Circle()
				.fill(roomColor)
				.frame(width: 75, height: 75)
		}
	}
}

#Preview {
	RoomColorView(roomColor: .red.opacity(0.5))
		.environment(GridEngine())
}
