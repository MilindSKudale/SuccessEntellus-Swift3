//
//  ApproveRequestCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 01/06/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class ApproveRequestCell: UITableViewCell {

    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblDate : UILabel!
    @IBOutlet var lblAccessModule : UILabel!
    @IBOutlet var imgView : UIImageView!
    @IBOutlet var accessModuleView : UIView!
    @IBOutlet var lblNoRequest : UILabel!
    
    @IBOutlet var btnAccept : UIButton!
    @IBOutlet var btnReject : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgView.layer.cornerRadius = imgView.frame.size.height/2
        imgView.layer.borderWidth = 0.3
        imgView.layer.borderColor = APPGRAYCOLOR.cgColor
        imgView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
