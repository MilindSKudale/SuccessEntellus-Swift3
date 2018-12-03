//
//  MyGroupCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 30/04/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class MyGroupCell: UITableViewCell {

    let lblGrType = UILabel()
    let lblGrTypeValues = UILabel()
    let lblGrMembers = UILabel()
    let lblGrMembersValues = UILabel()
    let lblViewMore = UILabel()
    let btnViewMore = UIButton()
    let btnEdit = UIButton()
    let btnDelete = UIButton()
    let btnAssignCampaign = UIButton()
    var tagGrType: [UIButton]!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(lblGrType)
        contentView.addSubview(lblGrMembers)
        contentView.addSubview(lblViewMore)
        contentView.addSubview(btnViewMore)
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
        
        lblGrType.frame = CGRect(x: 10, y: 5, width: self.contentView.frame.size.width - 20, height: 50)
        lblGrMembers.frame = CGRect(x: 10, y: 60, width: self.contentView.frame.size.width - 20, height: 50)
        btnViewMore.frame = CGRect(x: self.contentView.frame.size.width - 120, y: 110, width: 100, height: 30)
        lblViewMore.frame = CGRect(x: self.contentView.frame.size.width - 120, y: 139, width: 100, height: 1)
        
        btnEdit.frame = CGRect(x: self.contentView.frame.size.width - 120, y: 145, width: 30, height: 30)
        btnDelete.frame = CGRect(x: self.contentView.frame.size.width - 80, y: 145, width: 30, height: 30)
        btnAssignCampaign.frame = CGRect(x: self.contentView.frame.size.width - 40, y: 145, width: 30, height: 30)
        
    }
}
