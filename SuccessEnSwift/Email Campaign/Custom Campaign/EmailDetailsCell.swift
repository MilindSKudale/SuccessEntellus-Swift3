//
//  EmailDetailsCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 26/04/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class EmailDetailsCell: UITableViewCell {
    
    let lblEmail = UILabel()
    let lblPhone = UILabel()
    let lblDate = UILabel()
    let lblReadStatus = UILabel()
    
    // MARK: - Init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(lblEmail)
        contentView.addSubview(lblPhone)
        contentView.addSubview(lblDate)
        contentView.addSubview(lblReadStatus)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Base Class Overrides
    override func layoutSubviews() {
        super.layoutSubviews()
        
        lblEmail.frame = CGRect(x: 10, y: 3, width: self.contentView.frame.size.width - 20, height: 20)
        lblPhone.frame = CGRect(x: 10, y: 28, width: self.contentView.frame.size.width - 20, height: 20)
        lblDate.frame = CGRect(x: 10, y: 52, width: self.contentView.frame.size.width - 20, height: 20)
        lblReadStatus.frame = CGRect(x: 10, y: 76, width: self.contentView.frame.size.width - 20, height: 20)
        
        lblEmail.font = UIFont.systemFont(ofSize: 15.0)
        lblPhone.font = UIFont.systemFont(ofSize: 15.0)
        lblDate.font = UIFont.systemFont(ofSize: 15.0)
        lblReadStatus.font = UIFont.systemFont(ofSize: 15.0)
    }
}
