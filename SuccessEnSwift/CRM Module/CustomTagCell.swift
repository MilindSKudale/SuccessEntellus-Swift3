//
//  CustomTagCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 05/02/19.
//  Copyright © 2019 milind.kudale. All rights reserved.
//

import UIKit

class CustomTagCell: UITableViewCell {
    
    @IBOutlet var lblTagName : UILabel!
    @IBOutlet var btnRemove : UIButton!
    @IBOutlet var btnEdit : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
