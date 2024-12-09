//
//  Swift+Extension.swift
//  Core
//
//  Created by choijunios on 12/11/24.
//

import UIKit


public extension UIColor {
    
    static func color(_ hexString: String) -> UIColor? {

        var hexStringOnly = hexString
        
        if hexStringOnly.hasPrefix("#") {
            
            hexStringOnly.removeFirst()
        }
        
        guard hexStringOnly.count == 6 || hexStringOnly.count == 8 else { return nil }
        
        // Convert the string to UInt64
        var hexValue: UInt64 = 0
        Scanner(string: hexStringOnly).scanHexInt64(&hexValue)
        
        // Extract RGBA components
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        let alpha: CGFloat
        
        if hexStringOnly.count == 6 {
            // Format: RRGGBB
            red = CGFloat((hexValue >> 16) & 0xFF) / 255.0
            green = CGFloat((hexValue >> 8) & 0xFF) / 255.0
            blue = CGFloat(hexValue & 0xFF) / 255.0
            alpha = 1.0
        } else {
            // Format: RRGGBBAA
            red = CGFloat((hexValue >> 24) & 0xFF) / 255.0
            green = CGFloat((hexValue >> 16) & 0xFF) / 255.0
            blue = CGFloat((hexValue >> 8) & 0xFF) / 255.0
            alpha = CGFloat(hexValue & 0xFF) / 255.0
        }
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func toHexString(includeAlpha: Bool = false) -> String? {
        
        // Get the color's components
        guard let components = cgColor.components, components.count >= 3 else {
            return nil // Return nil if the color doesn't have RGB components
        }
        
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        let alpha = components.count >= 4 ? components[3] : 1.0
        
        if includeAlpha {
            return String(format: "#%02lX%02lX%02lX%02lX",
                          lround(Double(red * 255)),
                          lround(Double(green * 255)),
                          lround(Double(blue * 255)),
                          lround(Double(alpha * 255)))
        } else {
            return String(format: "#%02lX%02lX%02lX",
                          lround(Double(red * 255)),
                          lround(Double(green * 255)),
                          lround(Double(blue * 255)))
        }
    }
}
