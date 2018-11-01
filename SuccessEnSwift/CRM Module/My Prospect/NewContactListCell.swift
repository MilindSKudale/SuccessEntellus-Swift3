//
//  NewContactListCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 13/06/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class NewContactListCell: UITableViewCell {
    
    @IBOutlet var lblInitials : UILabel!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblContact : UILabel!
    @IBOutlet var btnSelect : UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblInitials.layer.cornerRadius = lblInitials.frame.height/2
        lblInitials.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
