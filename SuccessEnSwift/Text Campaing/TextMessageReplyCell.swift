//
//  TextMessageReplyCell.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 15/02/19.
//  Copyright © 2019 milind.kudale. All rights reserved.
//

import UIKit

class TextMessageReplyCell: UITableViewCell {
    
    @IBOutlet var userImage : UIImageView!
    @IBOutlet var lblUserName : UILabel!
    @IBOutlet var lblDate : UILabel!
    @IBOutlet var lblMessage : UILabel!
    @IBOutlet var lblPhoneNumber : UILabel!
    
    @IBOutlet var btnViewMore : UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(name: String) {
        lblUserName.text = name
        userImage?.setImage(string: name, color: UIColor.colorHash(name: name), circular: true)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userImage?.image = nil
        lblUserName.text = nil
    }

}


class ReplyDetailCell : UITableViewCell {

    @IBOutlet var lblDate : UILabel!
    @IBOutlet var lblMessage : UILabel!
    @IBOutlet var messageView : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.messageView.layer.cornerRadius = 10.0
        messageView.clipsToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
