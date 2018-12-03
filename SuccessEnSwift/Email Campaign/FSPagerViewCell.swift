//
//  FSPagerViewCell.swift
//  FSPagerView
//
//  Created by Wenchao Ding on 17/12/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

import UIKit

open class FSPagerViewCell: UICollectionViewCell {
    
    /// Returns the label used for the main textual content of the pager view cell.
    @objc
    open var textLabel: UILabel? {
        if let _ = _textLabel {
            return _textLabel
        }
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear//UIColor.black.withAlphaComponent(0.7)
        
        let textLabel = UILabel(frame: .zero)
        textLabel.textColor = .white
        textLabel.textAlignment = .center
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        textLabel.addObserver(self, forKeyPath: "font", options: [.old,.new], context: kvoContext)
        
        self.contentView.addSubview(view)
        view.addSubview(textLabel)

        _textLabel = textLabel
        return textLabel
    }
    @objc
    open var labelDays: UILabel? {
        if let _ = _labelDays {
            return _labelDays
        }
        let view = UILabel(frame: .zero)
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        
        let textLabel1 = UILabel(frame: .zero)
        textLabel1.textColor = .white
        textLabel1.font = UIFont.preferredFont(forTextStyle: .body)
        //textLabel.addObserver(self, forKeyPath: "font", options: [.old,.new], context: kvoContext)
        self.contentView.addSubview(view)
        view.addSubview(textLabel1)
        
        _labelDays = textLabel1
        return textLabel1
    }
    
    /// Returns the image view of the pager view cell. Default is nil.
    @objc
    open var imageView: UIImageView? {
        if let _ = _imageView {
            return _imageView
        }
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(imageView)
        _imageView = imageView
        return imageView
    }
    
    @objc
    open var btnDelete: UIButton? {
        if let _ = _btnDelete {
            return _btnDelete
        }
        let btn = UIButton(frame: .zero)
        btn.backgroundColor = .white
        btn.setImage(#imageLiteral(resourceName: "ic_close_orange"), for: .normal)
        btn.layer.cornerRadius = btn.frame.size.width/2
        self.contentView.addSubview(btn)
        _btnDelete = btn
        
        return btn
    }
    @objc
    open var btnEdit: UIButton? {
        if let _ = _btnEdit {
            return _btnEdit
        }
        let btnE = UIButton(frame: .zero)
        btnE.backgroundColor = APPGRAYCOLOR
        btnE.backgroundColor = APPGRAYCOLOR
        btnE.setImage(#imageLiteral(resourceName: "edit"), for: .normal)
        
        self.contentView.addSubview(btnE)
        _btnEdit = btnE
        
        return btnE
    }
    
    fileprivate weak var _textLabel: UILabel?
    fileprivate weak var _imageView: UIImageView?
    fileprivate weak var _labelDays: UILabel?
    fileprivate weak var _btnDelete: UIButton?
    fileprivate weak var _btnEdit: UIButton?
    
    fileprivate let kvoContext = UnsafeMutableRawPointer(bitPattern: 0)
    fileprivate let selectionColor = UIColor(white: 0.2, alpha: 0.2)
    
    fileprivate weak var _selectedForegroundView: UIView?
    fileprivate var selectedForegroundView: UIView? {
        guard _selectedForegroundView == nil else {
            return _selectedForegroundView
        }
        guard let imageView = _imageView else {
            return nil
        }
        
        
        let view = UIView(frame: imageView.bounds)
        imageView.addSubview(view)
        let imgVw = UIImageView(frame:CGRect(x: 0, y: 0, width: 50, height: 50))
        imgVw.center = view.center
        imgVw.image = nil
//        imgVw.contentMode = .scaleAspectFit
        view.addSubview(imgVw)
        _selectedForegroundView = view
        return view
    }
    
    open override var isHighlighted: Bool {
        set {
            super.isHighlighted = newValue
            if newValue {
                self.selectedForegroundView?.layer.backgroundColor = self.selectionColor.cgColor
            } else if !super.isSelected {
                self.selectedForegroundView?.layer.backgroundColor = UIColor.clear.cgColor
            }
        }
        get {
            return super.isHighlighted
        }
    }
    
    open override var isSelected: Bool {
        set {
            super.isSelected = newValue
            self.selectedForegroundView?.layer.backgroundColor = newValue ? self.selectionColor.cgColor : UIColor.clear.cgColor
        }
        get {
            return super.isSelected
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.contentView.backgroundColor = UIColor.white
        self.backgroundColor = UIColor.white
        self.contentView.layer.shadowColor = UIColor.black.cgColor
        self.contentView.layer.shadowRadius = 10
        self.contentView.layer.shadowOpacity = 0.75
        self.contentView.layer.shadowOffset = .zero
    }
    
    deinit {
        if let textLabel = _textLabel {
            textLabel.removeObserver(self, forKeyPath: "font", context: kvoContext)
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        if let imageView = _imageView {
            imageView.frame = self.contentView.bounds
        }
        if let textLabel = _textLabel {
            textLabel.superview!.frame = {
                var rect = self.contentView.bounds
                let height = textLabel.font.pointSize*2
                rect.size.height = height
                rect.origin.y = self.contentView.frame.height-height
                return rect
            }()
            textLabel.frame = {
                var rect = textLabel.superview!.bounds
                rect = rect.insetBy(dx: 8, dy: 0)
                rect.size.height -= 1
                rect.origin.y += 1
                return rect
            }()
        }
        if let textLabel1 = _labelDays {
            textLabel1.superview!.frame = {
                var rect = self.contentView.bounds
                let height = textLabel1.font.pointSize*2
                rect.size.height = height
                rect.origin.y = 0
                return rect
            }()
            textLabel1.frame = {
                var rect = textLabel1.superview!.bounds
                rect = rect.insetBy(dx: 8, dy: 0)
                rect.size.height -= 1
                rect.origin.y += 1
                return rect
            }()
        }

        if let btnEdt = _btnEdit {
            btnEdt.frame = CGRect(x: self.contentView.frame.size.width-75, y: 5, width: 30, height: 30)
            btnEdt.layer.cornerRadius = 15
        }
        
        if let btnDel = _btnDelete {
            btnDel.frame = CGRect(x: self.contentView.frame.size.width-35, y: 5, width: 30, height: 30)
            btnDel.layer.cornerRadius = 15
        }
        if let selectedForegroundView = _selectedForegroundView {
            selectedForegroundView.frame = self.contentView.bounds
        }
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == kvoContext {
            if keyPath == "font" {
                self.setNeedsLayout()
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
