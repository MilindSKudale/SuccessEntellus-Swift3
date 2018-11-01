//
//  TaskListCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 25/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class TaskListCell: UITableViewCell {

    @IBOutlet var lblEventName : UILabel!
    @IBOutlet var lblEventDetails : UILabel!
    @IBOutlet var lblStartTime : UILabel!
    @IBOutlet var lblEndTime : UILabel!
    @IBOutlet var uiView : UIView!
    @IBOutlet var btnEdit : UIButton!
    @IBOutlet var btnDelete : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        uiView.layer.cornerRadius = 10.0
        uiView.clipsToBounds = true
        
        btnEdit.layer.cornerRadius = 5.0
        btnEdit.layer.borderColor = UIColor.white.cgColor
        btnEdit.layer.borderWidth = 0.5
        btnEdit.clipsToBounds = true
        
        btnDelete.layer.cornerRadius = 5.0
        btnDelete.layer.borderColor = UIColor.white.cgColor
        btnDelete.layer.borderWidth = 0.5
        btnDelete.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
