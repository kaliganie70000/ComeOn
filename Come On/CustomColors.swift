//
//  CustomColors.swift
//  Come On
//
//  Created by Julien Colin on 19/04/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit

class CustomColors {
    
    static func gradientBlack70()   -> UIColor { return uicolorFromHex(0x000000, alpha: 1) }
    static func grey()              -> UIColor { return uicolorFromHex(0x676767) }
    static func notifBlue()         -> UIColor { return uicolorFromHex(0x44aaff) }
    static func notifRed()          -> UIColor { return uicolorFromHex(0xf44336) }
    static func purple()            -> UIColor { return uicolorFromHex(0x383460) }
    
    static func uicolorFromHex(rgbValue: UInt32, alpha a: CGFloat = 1.0) -> UIColor {
        let r = CGFloat((rgbValue & 0xff0000) >> 16) / 256.0
        let g = CGFloat((rgbValue & 0xff00) >> 8) / 256.0
        let b = CGFloat(rgbValue & 0xff) / 256.0
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}


extension CALayer {
    var borderUIColor: UIColor {
        set {
            self.borderColor = newValue.CGColor
        }
        
        get {
            return UIColor(CGColor: self.borderColor!)
        }
    }
}