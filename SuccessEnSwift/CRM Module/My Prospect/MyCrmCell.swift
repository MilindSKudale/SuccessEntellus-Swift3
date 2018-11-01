//
//  MyCrmCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 20/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class MyCrmCell: UITableViewCell {

    let lblEmail = UILabel()
    let lblPhone = UILabel()
    let lblTag = UILabel()
    let lblTagLine = UILabel()
    let btnTag = UIButton()
    let btnEdit = UIButton()
    let btnDelete = UIButton()
    let btnAssignCampaign = UIButton()
    
    
    // MARK: - Init
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(lblEmail)
        contentView.addSubview(lblPhone)
        contentView.addSubview(lblTag)
//        contentView.addSubview(lblTagLine)
        contentView.addSubview(btnTag)
        contentView.addSubview(btnEdit)
        contentView.addSubview(btnDelete)
        contentView.addSubview(btnAssignCampaign)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Base Class Overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        lblEmail.frame = CGRect(x: 40, y: 5, width: self.contentView.frame.size.width - 20, height: 20)
        lblPhone.frame = CGRect(x: 40, y: 27, width: self.contentView.frame.size.width - 20, height: 20)
        lblTag.frame = CGRect(x: 40, y: 54, width: 50, height: 20)
        btnTag.frame = CGRect(x: 90, y: 49, width: 150, height: 30)
        btnTag.layer.cornerRadius = btnTag.frame.size.height/2
        btnTag.layer.borderWidth = 1.0
        //btnTag.layer.borderColor = APPGRAYCOLOR.cgColor
        btnTag.clipsToBounds = true
      
        btnEdit.frame = CGRect(x: self.contentView.frame.size.width - 120, y: 84, width: 30, height: 30)
        btnDelete.frame = CGRect(x: self.contentView.frame.size.width - 80, y: 84, width: 30, height: 30)
        btnAssignCampaign.frame = CGRect(x: self.contentView.frame.size.width - 40, y: 84, width: 30, height: 30)
        
    }

}
