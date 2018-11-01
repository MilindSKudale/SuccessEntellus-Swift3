//
//  EventListCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 22/06/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class EventListCell: UITableViewCell {

    @IBOutlet var lblEventName : UILabel!
    @IBOutlet var lblEventDetails : UILabel!
    @IBOutlet var lblStartTime : UILabel!
    @IBOutlet var lblEndTime : UILabel!
    @IBOutlet var uiView : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        uiView.layer.cornerRadius = 10.0
        uiView.clipsToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
