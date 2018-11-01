//
//  DocumentListCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 16/07/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class DocumentListCell: UITableViewCell {
    
    @IBOutlet var lblDocTitle : UILabel!
    @IBOutlet var imgDoc : UIImageView!
    @IBOutlet var btnSelect : UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgDoc.layer.cornerRadius = 2
        imgDoc.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
