//
//  ColorsStepView.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 19/10/2026.
//

import SwiftUI

struct ColorsStepView: View {
	@Environment(GridEngine.self) private var engine
	
	var body: some View {
		VStack(spacing: 20) {
			Section {
				if engine.roomColors.isEmpty {
					ContentUnavailableView("Elige el número de espacios", systemImage: "paintbrush")
				} else {
					LazyVGrid(columns: [GridItem(.adaptive(minimum: 130))]) {
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
				Button("Siguiente") {
					engine.setupStep = .elements
				}
				.buttonStyle(.borderedProminent)
			}
		}
	}
}

#Preview {
	ColorsStepView()
		.environment(GridEngine())
}
