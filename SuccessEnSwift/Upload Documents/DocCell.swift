//
//  DocCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 09/07/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class DocCell: UITableViewCell {
    
    @IBOutlet var lblDocTitle : UILabel!
    @IBOutlet var vwCell : UIView!
    @IBOutlet var imgDoc : UIImageView!
    @IBOutlet var btnDownload : UIButton!
    @IBOutlet var btnDelete : UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        vwCell.layer.cornerRadius = 5.0
        vwCell.layer.borderColor = APPGRAYCOLOR.cgColor
        vwCell.layer.borderWidth = 0.25
        vwCell.clipsToBounds = true
        
        btnDelete.layer.cornerRadius = 5.0
        btnDelete.layer.borderColor = APPGRAYCOLOR.cgColor
        btnDelete.layer.borderWidth = 0.25
        btnDelete.clipsToBounds = true
        
        btnDownload.layer.cornerRadius = 5.0
        btnDownload.layer.borderColor = APPGRAYCOLOR.cgColor
        btnDownload.layer.borderWidth = 0.25
        btnDownload.clipsToBounds = true
        
        imgDoc.layer.cornerRadius = 3.0 //imgDoc.frame.size.height/2
        imgDoc.layer.borderColor = APPGRAYCOLOR.cgColor
        imgDoc.layer.borderWidth = 0.005
        imgDoc.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
