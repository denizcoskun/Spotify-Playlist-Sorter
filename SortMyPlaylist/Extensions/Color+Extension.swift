//
//  Color+Extension.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 12/07/2020.
//

import Foundation
import Hue
import SwiftUI

public extension Color {
    enum Spotify {
        static let black = Color(UIColor(hex: "191414"))
        static let green = Color(UIColor(hex: "1DB954"))
        static let darkGrey = Color(UIColor(hex: "282828"))
    }

    enum App {
        // https://coolors.co/ffbe0b-fb5607-ff006e-8338ec-3a86ff
        static let mango = Color(UIColor(hex: "FFBE0B"))
        static let orangePantone = Color(UIColor(hex: "FB5607"))
        static let winterSky = Color(UIColor(hex: "FF006E"))
        static let blueVelvet = Color(UIColor(hex: "8338EC"))
        static let azure = Color(UIColor(hex: "3A86FF"))
        // https://coolors.co/9b5de5-f15bb5-fee440-00bbf9-00f5d4
        static let capri = Color(UIColor(hex: "00BBF9"))
        static let magenta = Color(UIColor(hex: "F15BB5"))
        static let red = Color(UIColor(hex: "F15BB5"))
    }

    internal init(_ hex: UInt32, opacity: Double = 1.0) {
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0xFF00) >> 8) / 255.0
        let blue = Double((hex & 0xFF) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
