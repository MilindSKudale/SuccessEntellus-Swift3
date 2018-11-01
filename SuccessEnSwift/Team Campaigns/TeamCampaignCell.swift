//
//  TeamCampaignCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 15/10/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class TeamCampaignCell: UITableViewCell {
    
    @IBOutlet var lblCampaignTitle : UILabel!
    @IBOutlet var vwCell : UIView!
    @IBOutlet var imgView : UIImageView!
    @IBOutlet var btnOptions : UIButton!
    @IBOutlet var btnShareCamp : UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
