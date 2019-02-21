//
//  ViewDetailsVB.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 13/11/18.
//  Copyright © 2018 milind.kudale. All rights reserved.
//

import UIKit

class ViewDetailsVB: UIViewController, FSPagerViewDelegate, FSPagerViewDataSource {

    //@IBOutlet var imgVB : AACarousel!
    @IBOutlet var viewVB : UIView!
    @IBOutlet var txtVisionTitle : UITextField!
    @IBOutlet var txtVisionCategory : UITextField!
    @IBOutlet var txtVisionDesc : UITextView!
    @IBOutlet var txtVisionDesc2 : UITextView!
    @IBOutlet var btnCancel : UIButton!
    var arrVBData = [String:Any]()
    var vbId = ""
    
    var imageArray = [UIImage]()
    @IBOutlet var pageControl : UIPageControl!
    let viewImg = UIView()
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            //self.pagerView.layer.borderWidth = 1.0
            //self.pagerView.layer.borderColor = APPGRAYCOLOR.cgColor
        }
    }
    
    override func viewDidLoad() {
        print("Loaded!")
        designUI()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            getVisionBoardById()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
    }
    
    func configurePageControl() {
        self.pageControl.numberOfPages = self.imageArray.count
        self.pageControl.currentPage = 0
        //        self.pageControl.tintColor = UIColor.red
        //        self.pageControl.pageIndicatorTintColor = UIColor.cyan
        //        self.pageControl.currentPageIndicatorTintColor = UIColor.green
    }
    
    func getVisionBoardById(){
        
        if vbId == "" {
            return
        }
        
        let dictParam = ["userId": userID,
                         "platform":"3",
                         "vboardId":vbId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getVisionBoardById", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as AnyObject
                self.assignDataToFields(result)
                
                OBJCOM.hideLoader()
            }else{
                
                OBJCOM.setAlert(_title: "", message: "Cannot get response..")
                OBJCOM.hideLoader()
            }
        };
    }

    
    //getVisionBoardById
    
    func designUI(){
        
        viewVB.layer.cornerRadius = 10
        viewVB.clipsToBounds = true
        
        txtVisionDesc.layer.cornerRadius = 10.0
        txtVisionDesc.layer.borderWidth = 0.5
        txtVisionDesc.layer.borderColor = UIColor.lightGray.cgColor
        txtVisionDesc.clipsToBounds = true
        
        txtVisionDesc2.layer.cornerRadius = 10.0
        txtVisionDesc2.layer.borderWidth = 0.5
        txtVisionDesc2.layer.borderColor = UIColor.lightGray.cgColor
        txtVisionDesc2.clipsToBounds = true
        
        btnCancel.layer.cornerRadius = btnCancel.frame.height / 2
        btnCancel.clipsToBounds = true
        
        pagerView?.automaticSlidingInterval = 0.0
        pagerView?.isInfinite = true
        pagerView?.itemSize = CGSize(width: pagerView.frame.width, height: pagerView.frame.height)
        pagerView?.interitemSpacing = 0
        pagerView?.transformer = FSPagerViewTransformer(type: .overlap)
    
    }
    
    func assignDataToFields(_ data: AnyObject){
        txtVisionTitle.text = data["vboardTitle"] as? String ?? ""
        txtVisionCategory.text = data["vbCategory"] as? String ?? ""
        txtVisionDesc.text = data["vboardDescription"] as? String ?? ""
        txtVisionDesc2.text = data["vboardEmotion"] as? String ?? ""
    
        imageArray = []
        let imgUrlPath = data["filePath"] as? String ?? ""
        let arrimgUrl = data["vboardAttachment"] as! [AnyObject]
        if arrimgUrl.count > 0 {
            for obj in arrimgUrl {
                let imgUrl = obj["vbAttachmentFile"] as? String ?? ""
               
                if imgUrl != "" {
                    let url = URL(string: imgUrlPath+"\(userID)/"+imgUrl)
                   // print(url)
                   // DispatchQueue.global().async {
                        if let data = try? Data(contentsOf: url!) {
                           // DispatchQueue.main.async {
                                self.imageArray.append(UIImage(data: data)!)
                           // }
                        }
                   // }
                }
            }
        }else{
            self.imageArray = []
        }
        
//        txtVisionTitle.isUserInteractionEnabled = false
//        txtVisionCategory.isUserInteractionEnabled = false
//        txtVisionDesc.isUserInteractionEnabled = false
//        txtVisionDesc2.isUserInteractionEnabled = false
        self.configurePageControl()
        self.pagerView.reloadData()
    }
    
    @IBAction func actionDismiss(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    //require method
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.imageArray.count;
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        if pagerView == pagerView {
            cell.imageView?.image = imageArray[index]
            self.pageControl.currentPage = index
        }
        return cell
    }
    
    public func pagerView(_ pagerView:FSPagerView, didSelectItemAt index:Int) {
        self.pageControl.currentPage = index
    }

}
