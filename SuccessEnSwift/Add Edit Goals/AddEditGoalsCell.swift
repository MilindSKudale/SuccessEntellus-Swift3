//
//  AddEditGoalsCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 11/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class AddEditGoalsCell: UITableViewCell {
    
    @IBOutlet var lblGoalName : UILabel!
    @IBOutlet var txtRecomendedGoals : UITextField!
    @IBOutlet var txtPersonalGoals : UITextField!
    @IBOutlet var btnHelpTip : UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        txtPersonalGoals.rightViewMode = UITextFieldViewMode.always
        let uiView = UIView(frame: CGRect(x: 0, y: 0, width: txtPersonalGoals.frame.size.height, height: txtPersonalGoals.frame.size.height))
        let imageView = UIImageView(frame: CGRect(x: 7.5, y: 5, width: txtPersonalGoals.frame.size.height-15, height: txtPersonalGoals.frame.size.height-10))
        let image = #imageLiteral(resourceName: "popup_edit")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        uiView.addSubview(imageView)
        txtPersonalGoals.rightView = uiView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
