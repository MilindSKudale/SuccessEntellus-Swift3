//
//  CFTUserListCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 06/08/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class CFTUserListCell: UITableViewCell {

    @IBOutlet var imgCFT : UIImageView!
    @IBOutlet var lblCftName : UILabel!
    @IBOutlet var btnShowHide : UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgCFT.layer.cornerRadius = imgCFT.frame.size.height/2
        imgCFT.clipsToBounds = true
        
        btnShowHide.layer.cornerRadius = btnShowHide.frame.size.height/2
        btnShowHide.layer.borderColor = APPGRAYCOLOR.cgColor
        btnShowHide.layer.borderWidth = 1.0
        btnShowHide.clipsToBounds = true
        
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}


