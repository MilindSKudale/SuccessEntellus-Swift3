//
//  AccessSettingCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 01/06/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class AccessSettingCell: UITableViewCell {
    
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblDate : UILabel!
    @IBOutlet var lblAccessModule : UILabel!
    @IBOutlet var imgView : UIImageView!
    @IBOutlet var accessModuleView : UIView!
    
    @IBOutlet var btnEdit : UIButton!
    @IBOutlet var btnRemoveAccess : UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgView.layer.cornerRadius = imgView.frame.size.height/2
        imgView.layer.borderWidth = 0.3
        imgView.layer.borderColor = APPGRAYCOLOR.cgColor
        imgView.clipsToBounds = true
        
        btnEdit.layer.cornerRadius = btnEdit.frame.size.height/2
        btnEdit.clipsToBounds = true
        btnRemoveAccess.layer.cornerRadius = btnRemoveAccess.frame.size.height/2
        btnRemoveAccess.clipsToBounds = true
//        btnRemoveAccess.layer.cornerRadius = 5.0
//        btnRemoveAccess.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
