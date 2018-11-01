//
//  TabTitleView.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 07/03/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class TabTitleView: UIViewController {

    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 50, weight: UIFont.Weight.thin)
        label.textColor = APPORANGECOLOR
        label.text = title
        label.sizeToFit()
        
        view.addSubview(label)
        view.constrainCentered(label)
        view.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
