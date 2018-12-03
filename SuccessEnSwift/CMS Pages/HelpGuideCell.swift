//
//  HelpGuideCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 30/11/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class HelpGuideCell: UITableViewCell {
    
    @IBOutlet var lblDocName : UILabel!
    @IBOutlet var btnDownload : UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnDownload.layer.cornerRadius = 5.0
        btnDownload.layer.borderColor = APPGRAYCOLOR.cgColor
        btnDownload.layer.borderWidth = 0.5
        btnDownload.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
