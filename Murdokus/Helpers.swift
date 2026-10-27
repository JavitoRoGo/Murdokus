//
//  Helpers.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 26/10/2026.
//

import SwiftUI

enum ColorHelper {
	static func decomposeColor(_ color: Color) -> (red: Double, green: Double, blue: Double, opacity: Double) {
		let nsColor = NSColor(color)
		guard let sRGBColor = nsColor.usingColorSpace(.sRGB) else {
			// Si falla la conversión, devolvemos un color gris por defecto para no romper la app
			return (0.5, 0.5, 0.5, 1.0)
		}
		var r: CGFloat = 0
		var g: CGFloat = 0
		var b: CGFloat = 0
		var a: CGFloat = 0
		
		sRGBColor.getRed(&r, green: &g, blue: &b, alpha: &a)
		return (Double(r), Double(g), Double(b), Double(a))
	}

	static func composeColor(red: Double, green: Double, blue: Double, opacity: Double) -> Color {
		Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
	}
}
