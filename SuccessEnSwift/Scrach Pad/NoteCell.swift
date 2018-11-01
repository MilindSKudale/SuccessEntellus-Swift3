//
//  NoteCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 09/10/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {
    
    @IBOutlet var lblCreatedDate : UILabel!
    @IBOutlet var lblReminderDate : UILabel!
    @IBOutlet var lblNotesText : UILabel!
    @IBOutlet var btnEdit : UIButton!
    @IBOutlet var btnDelete : UIButton!
    @IBOutlet var btnViewNotes : UIButton!
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
