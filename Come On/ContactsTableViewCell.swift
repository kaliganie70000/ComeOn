//
//  ContactsTableViewCell.swift
//  Come On
//
//  Created by Julien Colin on 14/12/15.
//  Copyright © 2015 Julien Colin. All rights reserved.
//

import UIKit
import BEMCheckBox

class ContactsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet private weak var _pseudo: UILabel!

    @IBOutlet weak var constraintLeft: NSLayoutConstraint!
    @IBOutlet weak var constraintDetailsRight: NSLayoutConstraint!
    
    var pseudo: String? {
        didSet {
            _pseudo.text = "@\(pseudo!)"
        }
    }
    
    var isSelectible: Bool = true {
        didSet {
            if isSelectible { constraintDetailsRight.constant = 55 }
            else            { constraintDetailsRight.constant = 20 }
        }
    }
    
    var isInGroup: Bool = false {
        didSet {
            constraintLeft.constant = isInGroup == true ? 40 : 20
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        label.textColor = CustomColors.grey()
        isSelectible = false
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
