//
//  TimeAnalysisCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 25/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class TimeAnalysisCell: UITableViewCell {
    
    @IBOutlet var lblTotalTimeSpend : UILabel!
    @IBOutlet var lblSummery : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

   
}


//class TimeAnalysisCell: UITableViewCell {
//
//    @IBOutlet var lblTotalTimeSpend = UILabel()
//    let lblSummery = UILabel()
//
//    // MARK: - Init
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        contentView.addSubview(lblTotalTimeSpend)
//        contentView.addSubview(lblSummery)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // MARK: - Base Class Overrides
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        lblTotalTimeSpend.frame = CGRect(x: 10, y: 5, width: self.contentView.frame.size.width - 20, height: 20)
//        lblSummery.frame = CGRect(x: 10, y: 28, width: self.contentView.frame.size.width - 20, height: 20)
//    }
//}

