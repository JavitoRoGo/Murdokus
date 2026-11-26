//
//  CellView.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 20/10/2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct CellView: View {
	let cell: Cell
	let row: Int
	let col: Int
	@Environment(GridEngine.self) private var engine

	@State private var isTargeted: Bool = false
	@State private var isValidTarget: Bool = false

	var body: some View {
		ZStack {
			cell.color
				.frame(width: 80, height: 80)
                .overlay(hoverOverlay)
                .background(hoverBackground)
				.border(Color.black.opacity(0.1), width: 0.5)

            ForEach(cell.elements) { object in
                icon(for: object)
					.font(.system(size: 60))
                    .frame(width: 60, height: 60)
                    .foregroundColor(.black.opacity(0.7))
            }

            if !candidateLetters.isEmpty {
				candidateMarker
			}
		}
		.dropDestination(for: MurdokuTransferPackage.self) { incomingPackages, _ in
			guard let package = incomingPackages.first else { return false }
			engine.handleIntent(.move(package: package, destinationRow: row, destinationCol: col))
			return true
		} isTargeted: { targeted in
			if targeted {
				isTargeted = targeted

				if let dragging = engine.draggingObject {
					isValidTarget = engine.canPlaceObject(atRow: row, col: col, newObject: dragging)
				} else {
					isValidTarget = false
				}
			} else {
				isTargeted = false
				isValidTarget = false
			}
		}
        .onDrag {
            if let topObject = cell.elements.last {
				engine.draggingObject = topObject
                return NSItemProvider(object: MurdokuObjectProvider(object: topObject, row: row, col: col))
            } else {
                return NSItemProvider()
            }
        } preview: {
            if let topObject = cell.elements.last {
                icon(for: topObject)
					.font(.largeTitle)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.black.opacity(0.7))
                    .padding(10)
                    .background(Circle().fill(.ultraThinMaterial))
            } else {
                Color.clear
            }
        }
	}
	
	@ViewBuilder
	private func icon(for object: MurdokuObject) -> some View {
		object.element.icon(for: object.capitalLetter ?? "")
	}

	@ViewBuilder
	private var hoverBackground: some View {
		if isTargeted && engine.draggingObject?.element == .suspect {
			Color(isValidTarget ? .green : .red).opacity(0.2)
		} else {
			Color.clear
		}
	}

	@ViewBuilder
	private var hoverOverlay: some View {
		if isTargeted && engine.draggingObject?.element == .suspect {
			Rectangle()
				.stroke(isValidTarget ? Color.green : Color.red, lineWidth: 3)
		} else {
			Color.clear
		}
	}

	/// The candidate markers of the current cell, rendered as an array of letters.
	private var candidateLetters: [String] {
		engine.suspectCandidates
			.filter { _, positions in positions.contains(CellKey(row: row, col: col)) }
			.map { $0.key }
			.sorted()
	}

	/// The maximum number of candidate letters rendered in a single row.
	private let maximumCandidateRowCount = 3

	/// Groups the candidate letters of the current cell into rows of at most `maximumCandidateRowCount` letters.
	private var candidateRows: [[String]] {
		var rows: [[String]] = []
		var currentRow: [String] = []

		for letter in candidateLetters {
			currentRow.append(letter)
			if currentRow.count >= maximumCandidateRowCount {
				rows.append(currentRow)
				currentRow = []
			}
		}

		if !currentRow.isEmpty {
			rows.append(currentRow)
		}

		return rows
	}

	/// The candidate marker of the current cell, rendered in the top-leading corner.
	private var candidateMarker: some View {
		VStack(alignment: .leading, spacing: 10) {
			ForEach(candidateRows, id: \.self) { row in
				HStack(spacing: 10) {
					ForEach(row, id: \.self) { letter in
						Text(letter)
							.font(.system(size: 14, weight: .bold))
							.foregroundColor(.primary)
					}
				}
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
	}
}
