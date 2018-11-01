//
//  CustomCampCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 23/04/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class CustomCampCell: UITableViewCell {
    
    @IBOutlet var viewBg : UIView!
    @IBOutlet var btnMoreOptions : UIButton!
    @IBOutlet var btnAddEmail : UIButton!
    @IBOutlet var lblCustomCampaign : UILabel!
    @IBOutlet var CustomCampaignIcon : UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.cornerRadius = 5.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
