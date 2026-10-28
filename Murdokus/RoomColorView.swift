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
				.scaleEffect(engine.activePaintColor == roomColor ? 1.1 : 1.0)
				.overlay {
					if engine.activePaintColor == roomColor {
						Circle()
							.stroke(.white, lineWidth: 3)
							.shadow(radius: 2)
					}
				}
				.animation(.spring(response: 0.3, dampingFraction: 0.6), value: engine.activePaintColor)
		}
		.frame(width: 120)
		.padding(10)
		.background {
			Capsule()
				.fill(.ultraThinMaterial)
		}
		.onTapGesture {
			engine.activePaintColor = roomColor
		}
	}
}

#Preview {
	RoomColorView(roomColor: .red.opacity(0.5))
		.environment(GridEngine())
}
