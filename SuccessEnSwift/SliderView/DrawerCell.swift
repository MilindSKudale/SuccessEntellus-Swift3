//
//  DrawerCell.swift
//  NavigationDrawer
//
//  Created by Sowrirajan Sugumaran on 05/10/17.
//  Copyright © 2017 Sowrirajan Sugumaran. All rights reserved.
//

import UIKit

class DrawerCell: UITableViewCell {

    @IBOutlet weak var lblController: UILabel!
    @IBOutlet weak var imgController: UIImageView!
    @IBOutlet weak var pkgAvailable: UIImageView!
    @IBOutlet weak var btnSelectCell: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        pkgAvailable.layer.cornerRadius = pkgAvailable.frame.height/2
        pkgAvailable.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class DrawerSubmenuCell: UITableViewCell {
    
    @IBOutlet weak var lblController: UILabel!
    @IBOutlet weak var imgController: UIImageView!
    @IBOutlet weak var pkgAvailable: UIImageView!
    @IBOutlet weak var btnSelectSubCell: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        pkgAvailable.layer.cornerRadius = pkgAvailable.frame.height/2
        pkgAvailable.clipsToBounds = true
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
