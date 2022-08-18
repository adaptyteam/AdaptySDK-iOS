//
//  UIColorExtensions.swift
//  Adapty_Example
//
//  Created by Aleksey Goncharov on 17.08.2022.
//  Copyright © 2022 Adapty. All rights reserved.
//

import UIKit

extension UIColor {
    static func fromHex(hexString: String, alpha: CGFloat = 1.0) -> UIColor {
        // Convert hex string to an integer
        let hexint = Int(Self.intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xFF) >> 0) / 255.0

        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }

    private static func intFromHexString(hexStr: String) -> UInt32 {
        var hexInt: UInt32 = 0
        // Create scanner
        let scanner: Scanner = Scanner(string: hexStr)
        // Tell scanner to skip the # character
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        // Scan hex value
        hexInt = UInt32(bitPattern: scanner.scanInt32(representation: .hexadecimal) ?? 0)
        return hexInt
    }
}
