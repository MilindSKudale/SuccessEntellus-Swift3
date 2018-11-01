//
//  MyExpandableTableViewSectionHeader.swift
//  LUExpandableTableViewExample
//
//  Created by Laurentiu Ungur on 24/11/2016.
//  Copyright © 2016 Laurentiu Ungur. All rights reserved.
//

import UIKit
import LUExpandableTableView

final class MyExpandableTableViewSectionHeader: LUExpandableTableViewSectionHeader {
    // MARK: - Properties
    
    @IBOutlet weak var expandCollapseButton: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    override var isExpanded: Bool {
        didSet {
            // Change the title of the button when section header expand/collapse
            expandCollapseButton?.setImage(isExpanded ? #imageLiteral(resourceName: "up-arrow") : #imageLiteral(resourceName: "right-arrow"), for: .normal)
            
        }
    }
    
    // MARK: - Base Class Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        label?.numberOfLines = 0
        label?.lineBreakMode = .byWordWrapping
        label?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnLabel)))
        label?.isUserInteractionEnabled = true
    }
    
    // MARK: - IBActions
    @IBAction func expandCollapse(_ sender: UIButton) {
        // Send the message to his delegate that shold expand or collapse
        delegate?.expandableSectionHeader(self, shouldExpandOrCollapseAtSection: section)
    }
    
    // MARK: - Private Functions
    @objc private func didTapOnLabel(_ sender: UIGestureRecognizer) {
        // Send the message to his delegate that was selected
        delegate?.expandableSectionHeader(self, wasSelectedAtSection: section)
    }
}

