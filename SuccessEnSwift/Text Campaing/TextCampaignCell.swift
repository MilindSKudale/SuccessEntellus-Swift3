//
//  TextCampaignCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 30/06/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class TextCampaignCell: UITableViewCell {
    
    @IBOutlet var lblCampaignTitle : UILabel!
    @IBOutlet var vwCell : UIView!
    @IBOutlet var imgView : UIImageView!
    @IBOutlet var btnOptions : UIButton!
   // @IBOutlet var viewBg : UIView!
   // @IBOutlet var CustomCampaignIcon : UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        vwCell.layer.cornerRadius = 5.0
        vwCell.layer.borderColor = APPGRAYCOLOR.cgColor
        vwCell.layer.borderWidth = 0.25
        imgView.layer.cornerRadius = imgView.frame.size.height/2
        imgView.clipsToBounds = true
        vwCell.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
