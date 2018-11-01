//
//  ScratchNotificationCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 10/10/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class ScratchNotificationCell: UITableViewCell {

    @IBOutlet var lblCreatedDate : UILabel!
    @IBOutlet var lblReminderDate : UILabel!
    @IBOutlet var lblNotesText : UILabel!
    @IBOutlet var lblNoNotes : UILabel!
    @IBOutlet var viewNotes : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewNotes.layer.cornerRadius = 5
        viewNotes.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
