//
//  ElementsView.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 19/10/2026.
//

import SwiftUI

struct ElementsView: View {
	@Environment(GridEngine.self) private var engine
	
    var body: some View {
		let columns = [GridItem(.adaptive(minimum: 130))]
		
		ScrollView {
			Section {
				LazyVGrid(columns: columns) {
					ForEach(engine.objects) { object in
						SingleElementView(object: object)
					}
				}
			} header: {
				Text("Elementos")
					.font(.headline)
			}
			
			Divider()
			
			Section {
				LazyVGrid(columns: columns) {
					ForEach(engine.suspects) { object in
						SingleElementView(object: object)
					}
				}
			} header: {
				Text("Sospechosos")
					.font(.headline)
					.padding(.vertical, 10)
			}
		}
		.frame(minWidth: 300)
		.padding()
    }
}

#Preview {
    ElementsView()
		.environment(GridEngine(rows: 5, columns: 5, numOfSuspects: 3))
}
