//
//  CalendarTableViewCell.swift
//  Come On
//
//  Created by Antoine roy on 05/01/2016.
//  Copyright © 2016 Julien Colin. All rights reserved.
//

import UIKit

class CalendarTableViewCell: UITableViewCell {

    @IBOutlet weak var labelDayDate: UILabel!
    @IBOutlet weak var labelMonthDate: UILabel!
    var item: DateItem!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
