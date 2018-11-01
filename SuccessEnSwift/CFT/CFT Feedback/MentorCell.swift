//
//  MentorCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 22/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class MentorCell: UITableViewCell {

    @IBOutlet var imgMentor : UIImageView!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblCount : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lblCount.layer.cornerRadius = self.lblCount.frame.height/2
        self.lblCount.clipsToBounds = true
        
        self.imgMentor.layer.cornerRadius = self.imgMentor.frame.height/2
        self.imgMentor.layer.borderColor = APPGRAYCOLOR.cgColor
        self.imgMentor.layer.borderWidth = 0.5
        self.imgMentor.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
