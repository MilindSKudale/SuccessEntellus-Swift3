//
//  EditGroupCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 03/05/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class EditGroupCell: UITableViewCell {
    
    @IBOutlet var lblName : UILabel!
    @IBOutlet var imgSelectBox : UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
