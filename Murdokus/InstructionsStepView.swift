//
//  InstructionsStepView.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 19/10/2026.
//

import SwiftUI

struct InstructionsStepView: View {
	@Environment(GridEngine.self) private var engine
	
	let onBack: () -> Void
	let onSave: () -> Void
	
	var body: some View {
		VStack(spacing: 20) {
			Text("Instrucciones")
				.font(.title)
				.multilineTextAlignment(.center)
			
			// TODO: Add the static instructions content in a future iteration.
			
			VStack(spacing: 12) {
				Button("Atrás") {
					onBack()
				}
				.buttonStyle(.bordered)
				
				Button("Guardar partida") {
					onSave()
				}
				.buttonStyle(.bordered)
				
				Button {
					withAnimation {
						engine.activePaintColor = nil
						engine.handleTimer(.start)
						engine.showingSuspects = true
					}
				} label: {
					Text("Comenzar")
						.font(.largeTitle)
				}
				.buttonStyle(.borderedProminent)
			}
		}
	}
}

#Preview {
	InstructionsStepView(onBack: {}, onSave: {})
		.environment(GridEngine())
}
