//
//  PhoneCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 18/12/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class PhoneCell: UITableViewCell {

    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblEmail : UILabel!
    @IBOutlet var lblDate : UILabel!
    @IBOutlet var lblCreditAmount : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
