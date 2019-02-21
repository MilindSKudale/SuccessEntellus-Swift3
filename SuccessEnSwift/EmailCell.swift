//
//  EmailCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 18/12/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class EmailCell: UITableViewCell {
    
    @IBOutlet var txtEmail : UITextField!
    @IBOutlet var txtPhone : UITextField!
    @IBOutlet var btnAddEmailField : UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        txtEmail.layer.cornerRadius = 5
        txtEmail.layer.borderColor = APPGRAYCOLOR.cgColor
        txtEmail.layer.borderWidth = 0.4
        txtEmail.clipsToBounds = true
        
        txtPhone.layer.cornerRadius = 5
        txtPhone.layer.borderColor = APPGRAYCOLOR.cgColor
        txtPhone.layer.borderWidth = 0.4
        txtPhone.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
