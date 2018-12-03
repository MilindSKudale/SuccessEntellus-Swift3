//
//  VBCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 13/11/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class VBCell: UITableViewCell {
    
    @IBOutlet var uiView : UIView!
    @IBOutlet var imgView : UIImageView!
    @IBOutlet var lblCategory : UILabel!
    @IBOutlet var lblTitle : UILabel!
    @IBOutlet var lblDescription : UILabel!
    @IBOutlet var lblCreatedDate : UILabel!

    @IBOutlet var btnEdit : UIButton!
    @IBOutlet var btnDelete : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        uiView.layer.cornerRadius = 10.0
        uiView.layer.borderColor = APPGRAYCOLOR.cgColor
        uiView.layer.borderWidth = 0.2
        uiView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
