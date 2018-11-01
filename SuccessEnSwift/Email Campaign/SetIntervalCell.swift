//
//  SetIntervalCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 30/08/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class SetIntervalCell: UITableViewCell {
    
    @IBOutlet var btnImmediate : UIButton!
    @IBOutlet var lblTitle : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class SetIntervalScheduleCell: UITableViewCell {
    
    @IBOutlet var btnSchedule : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class SetIntervalRepeatCell: UITableViewCell {
    
    @IBOutlet var btnRepeat : UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
