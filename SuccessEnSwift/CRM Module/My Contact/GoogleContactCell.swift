//
//  GoogleContactCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 23/10/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class GoogleContactCell: UITableViewCell {
    
    @IBOutlet var imgSelect : UIImageView!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblEmail : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
