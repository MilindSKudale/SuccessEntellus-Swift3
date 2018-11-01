//
//  MyTableViewCell.swift
//  LUExpandableTableViewExample
//
//  Created by Laurentiu Ungur on 24/11/2016.
//  Copyright © 2016 Laurentiu Ungur. All rights reserved.
//

import UIKit

final class MyTableViewCell: UITableViewCell {
    // MARK: - Properties
    
    let lblWeeklyGoals = UILabel()
    let lblGoalCount = UILabel()
    let lblRemainingGoalCount = UILabel()
    let lblScore = UILabel()

    // MARK: - Init
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(lblWeeklyGoals)
        contentView.addSubview(lblGoalCount)
        contentView.addSubview(lblRemainingGoalCount)
        contentView.addSubview(lblScore)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Base Class Overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        lblWeeklyGoals.frame = CGRect(x: 10, y: 5, width: self.contentView.frame.size.width - 20, height: 20)
        lblGoalCount.frame = CGRect(x: 10, y: 27, width: self.contentView.frame.size.width - 20, height: 20)
        lblScore.frame = CGRect(x: 10, y: 49, width: self.contentView.frame.size.width - 20, height: 20)
        lblRemainingGoalCount.frame = CGRect(x: 10, y: 71, width: self.contentView.frame.size.width - 20, height: 20)
        
    }
}
