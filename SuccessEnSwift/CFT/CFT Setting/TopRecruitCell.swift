//
//  TopRecruitCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 02/06/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class TopRecruitCell: UITableViewCell {
    
    @IBOutlet var imgView : UIImageView!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblCount : UILabel!
    @IBOutlet var lblNoRecord : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblCount.layer.cornerRadius = lblCount.frame.height/2
        lblCount.clipsToBounds = true
        
        imgView.layer.cornerRadius = imgView.frame.height/2
        imgView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
