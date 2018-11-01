//
//  DailyTopTenCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 20/07/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class DailyTopTenCell: UITableViewCell {
    
    @IBOutlet var lblRecruitName : UILabel!
    @IBOutlet var lblScore : UILabel!
    //@IBOutlet var imgProfile : UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblScore.layer.cornerRadius = lblScore.frame.size.height/2
        lblScore.clipsToBounds = true
        
//        imgProfile.layer.cornerRadius = imgProfile.frame.size.height/2
//        imgProfile.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
