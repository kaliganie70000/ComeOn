//
//  ContactsTableViewHeader.swift
//  Come On
//
//  Created by Julien Colin on 13/01/16.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit
import BEMCheckBox

class ContactsTableViewHeader: UITableViewHeaderFooterView {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var accessor: UIImageView!
    @IBOutlet weak var checkbox: BEMCheckBox!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var constraintDetailsRight: NSLayoutConstraint!
    
    var isSelectible: Bool = true {
        didSet {
            if isSelectible { constraintDetailsRight.constant = 55 }
            else            { constraintDetailsRight.constant = 20 }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        label.textColor = CustomColors.grey()
        isSelectible = false
    }
    
}
