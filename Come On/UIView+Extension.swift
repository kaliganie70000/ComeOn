//
//  UIView+Extension.swift
//  Come On
//
//  Created by Julien Colin on 11/07/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit

extension UIView {
    
    func copyView() -> AnyObject {
        return NSKeyedUnarchiver.unarchiveObjectWithData(NSKeyedArchiver.archivedDataWithRootObject(self))!
    }
}
