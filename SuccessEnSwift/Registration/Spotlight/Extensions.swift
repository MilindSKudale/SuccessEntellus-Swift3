//
//  Extensions.swift
//  Walkthrough
//
//  Created by Ömer Faruk Öztürk on 29/09/2016.
//  Copyright © 2016 omerfarukozturk. All rights reserved.
//

import UIKit

extension UIView {
    func getGlobalPoint(toView: UIView? = UIApplication.shared.delegate?.window!) -> CGPoint {
        return self.superview!.convert(self.frame.origin, to: toView)
    }
}
