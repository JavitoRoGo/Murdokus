//
//  ElementsStepView.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 19/10/2026.
//

import SwiftUI

struct ElementsStepView: View {
	@Environment(GridEngine.self) private var engine
	
	var body: some View {
		VStack(spacing: 20) {
			Section {
				LazyVGrid(columns: [GridItem(.adaptive(minimum: 130))]) {
					ForEach(engine.objects) { object in
						SingleElementView(object: object)
					}
				}
			} header: {
				Text("Elementos")
					.font(.headline)
					.padding(.vertical, 10)
			}
			
			HStack(spacing: 10) {
				Button("Atrás") {
					engine.setupStep = .colors
				}
				.buttonStyle(.bordered)
				
				Button("Siguiente") {
					engine.setupStep = .instructions
				}
				.buttonStyle(.borderedProminent)
			}
		}
	}
}

#Preview {
	ElementsStepView()
		.environment(GridEngine())
}
