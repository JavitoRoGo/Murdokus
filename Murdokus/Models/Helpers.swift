//
//  Helpers.swift
//  Murdokus
//
//  Created by Javier Rodríguez Gómez on 26/10/2026.
//

import SwiftUI

/// A utility namespace providing methods to decompose and compose SwiftUI colors.
///
/// `ColorHelper` is primarily used for serializing and deserializing color data by
/// converting `Color` objects into their raw RGBA components and vice versa.
enum ColorHelper {
	/// Decomposes a SwiftUI `Color` into its individual sRGB components.
	///
	/// This method converts the provided `Color` to an `NSColor` in the sRGB color space
	/// to ensure consistent coordinate extraction.
	///
	/// - Parameter color: The SwiftUI `Color` to decompose.
	/// - Returns: A tuple containing the red, green, blue, and opacity components as `Double` values (0.0 to 1.0).
	/// - Note: If the color cannot be converted to the sRGB color space, a default gray color is returned.
	static func decomposeColor(_ color: Color) -> (red: Double, green: Double, blue: Double, opacity: Double) {
		let nsColor = NSColor(color)
		guard let sRGBColor = nsColor.usingColorSpace(.sRGB) else {
			return (0.5, 0.5, 0.5, 1.0)
		}
		var r: CGFloat = 0
		var g: CGFloat = 0
		var b: CGFloat = 0
		var a: CGFloat = 0
		
		sRGBColor.getRed(&r, green: &g, blue: &b, alpha: &a)
		return (Double(r), Double(g), Double(b), Double(a))
	}

	/// Composes a SwiftUI `Color` from raw sRGB components.
	///
	/// - Parameters:
	///   - red: The red component (0.0 to 1.0).
	///   - green: The green component (0.0 to 1.0).
	///   - blue: The blue component (0.0 to 1.0).
	///   - opacity: The opacity/alpha component (0.0 to 1.0).
	/// - Returns: A SwiftUI `Color` object constructed from the provided sRGB values.
	static func composeColor(red: Double, green: Double, blue: Double, opacity: Double) -> Color {
		Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
	}
}
