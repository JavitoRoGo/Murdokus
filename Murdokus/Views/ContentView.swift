//
//  ContentView.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 18/10/2026.
//

import SwiftUI

struct ContentView: View {
	@Environment(GridEngine.self) private var engine
	
	var body: some View {
		NavigationSplitView {
			SidebarView()
		} content: {
			ElementsView()
		} detail: {
			GridView()
		}

	}
}

#Preview {
	ContentView()
		.environment(GridEngine())
}
