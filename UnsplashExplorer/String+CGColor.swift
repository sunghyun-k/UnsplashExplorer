//
//  CGColor.swift
//  UnsplashExplorer
//
//  Created by Sunghyun Kim on 2022/03/22.
//

import Foundation
import CoreGraphics

extension String {
    var cgColor: CGColor? {
        guard count == 7,
              first == "#" else {
            return nil
        }
        let redHex = self[index(startIndex, offsetBy: 1)...index(startIndex, offsetBy: 2)]
        let greenHex = self[index(startIndex, offsetBy: 3)...index(startIndex, offsetBy: 4)]
        let blueHex = self[index(startIndex, offsetBy: 5)...index(startIndex, offsetBy: 6)]
        
        guard let red = UInt8(redHex, radix: 16),
              let green = UInt8(greenHex, radix: 16),
              let blue = UInt8(blueHex, radix: 16) else {
            return nil
        }
        return CGColor(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: 1
        )
    }
    
}
