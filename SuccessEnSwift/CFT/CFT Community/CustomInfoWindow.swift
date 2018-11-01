//
//  CustomInfoWindow.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 23/07/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class CustomInfoWindow: UIView {
    
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblEmail : UILabel!
    @IBOutlet var lblPhone : UILabel!
    @IBOutlet var lblDistance : UILabel!
    @IBOutlet var lblTimeStamp : UILabel!
    @IBOutlet var imgProfile : UIImageView!

}


class AddressInfoWindow: UIView {
    
    @IBOutlet var lblOfficeName : UILabel!
    @IBOutlet var lblAddress : UILabel!
    @IBOutlet var lblEmail : UILabel!
    @IBOutlet var lblDistance : UILabel!
}
