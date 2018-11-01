//
//  AssignCampaignCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 09/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class AssignCampaignCell: UITableViewCell {
    
    @IBOutlet var lblCampaignName : UILabel!
    @IBOutlet var btnUnAssignCampaign : UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
