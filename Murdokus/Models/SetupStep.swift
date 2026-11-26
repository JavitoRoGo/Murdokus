//
//  SetupStep.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 19/10/2026.
//

/// The sequential stages of the game setup flow presented in the central panel.
///
/// The flow guides the player through the configuration of a new game: first the room
/// colors are selected, then the furniture elements to place are chosen, and finally the
/// static instructions are shown before the game starts.
enum SetupStep {
	/// The stage where the player selects the room colors of the board.
	case colors
	
	/// The stage where the player selects the elements to place on the board.
	case elements
	
	/// The stage where the static instructions are shown before starting the game.
	case instructions
}
