//
//  ChecklistTableViewCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 08/02/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class ChecklistTableViewCell: UITableViewCell {
    
    @IBOutlet weak var btnHideGoals: UIButton!
    @IBOutlet weak var lblGoalName: UILabel!
    @IBOutlet weak var lblDefaultValues: UILabel!
    @IBOutlet weak var txtCompletedGoal: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        txtCompletedGoal.layer.cornerRadius = 5.0
        txtCompletedGoal.layer.borderWidth = 0.4
        txtCompletedGoal.layer.borderColor = APPGRAYCOLOR.cgColor
        txtCompletedGoal.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
