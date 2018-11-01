//
//  RemoveMemberCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 11/10/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class RemoveMemberCell: UITableViewCell {
    
    @IBOutlet var imgView : UIImageView!
    @IBOutlet var lblMemberName : UILabel!
    @IBOutlet var lblMemberPhone : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
