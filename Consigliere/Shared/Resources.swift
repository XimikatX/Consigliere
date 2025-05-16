//
//  Resources.swift
//  Consigliere
//
//  Created by Aleksey Boris on 30/04/2025.
//

import UIKit

enum R {
    
    enum Colors {
        
        enum Label {
            static var primary = UIColor(fromHex: 0x02031D)
        }
        
    }
    
}

extension UIColor {
    convenience init(fromHex hex: UInt64) {
        self.init(
            red: CGFloat((hex & 0xff0000) >> 16) / 255,
            green: CGFloat((hex & 0x00ff00) >> 8) / 255,
            blue: CGFloat((hex & 0x0000ff) >> 0) / 255,
            alpha: 1
        )
    }
    
    static var brandBlue = UIColor(fromHex: 0x5858C1)
    static var ghostWhite = UIColor(fromHex: 0xF1F1F9)
    
    static var imperialRed = UIColor(fromHex: 0xFD4949)
}

