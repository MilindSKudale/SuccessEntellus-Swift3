//
//  DetailViewController.swift
//  Demo
//
//  Created by Paolo Cuscela on 03/11/17.
//  Copyright © 2017 Paolo Cuscela. All rights reserved.
//

import UIKit
import ALCameraViewController
import Alamofire
import SwiftyJSON

var arrVBCategoryTitle = [String]()
var arrVBCategoryId = [String]()
var category = ""

class DetailsVB: UIViewController, FSPagerViewDataSource, FSPagerViewDelegate  {

    @IBOutlet var txtVisionTitle : UITextField!
    @IBOutlet var txtVisionCategory : UITextField!
    @IBOutlet var txtVisionDesc : UITextView!
    @IBOutlet var txtVisionDesc2 : UITextView!
    @IBOutlet var btnCancel : UIButton!
    @IBOutlet var btnEdit : UIButton!
    
    
    var arrVBImageId = [String]()
    
    var vbId = ""
    
    let viewImg = UIView()
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
            self.pagerView.layer.borderWidth = 1.0
            self.pagerView.layer.borderColor = APPGRAYCOLOR.cgColor
        }
    }
    var pageControl : UIPageControl = UIPageControl()
    var arrVBData = [String:Any]()
    var imageArray = [UIImage]()
    
    override func viewDidLoad() {
        print("Loaded!")
        designUI()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if OBJCOM.isConnectedToNetwork(){
            OBJCOM.setLoader()
            self.getVisionBoardCategory()
            self.getVisionBoardById()
        }else{
            OBJCOM.NoInternetConnectionCall()
        }
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
                
            }else{
                
                OBJCOM.setAlert(_title: "", message: "Cannot get response..")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func designUI(){
        
        txtVisionCategory.rightViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: txtVisionCategory.frame.width - 70, y: 0, width: 20, height: txtVisionCategory.frame.height))
        imageView.image = #imageLiteral(resourceName: "arrow-down")
        imageView.contentMode = .center
        txtVisionCategory.rightView = imageView
        
        
        txtVisionDesc.layer.cornerRadius = 5.0
        txtVisionDesc.layer.borderWidth = 0.2
        txtVisionDesc.layer.borderColor = UIColor.lightGray.cgColor
        txtVisionDesc.clipsToBounds = true
        
        txtVisionDesc2.layer.cornerRadius = 5.0
        txtVisionDesc2.layer.borderWidth = 0.2
        txtVisionDesc2.layer.borderColor = UIColor.lightGray.cgColor
        txtVisionDesc2.clipsToBounds = true
        
        btnEdit.layer.cornerRadius = btnEdit.frame.height / 2
        btnEdit.clipsToBounds = true
        
        btnCancel.layer.cornerRadius = btnCancel.frame.height / 2
        btnCancel.clipsToBounds = true
    }
    
    func assignDataToFields(_ data: AnyObject){
        txtVisionTitle.text = data["vboardTitle"] as? String ?? ""
        txtVisionCategory.text = data["vbCategory"] as? String ?? ""
        txtVisionDesc.text = data["vboardDescription"] as? String ?? ""
        txtVisionDesc2.text = data["vboardEmotion"] as? String ?? ""
        
        if txtVisionCategory.text != "" {
            if arrVBCategoryTitle.contains(txtVisionCategory.text!) {
                let index = arrVBCategoryTitle.index(of:txtVisionCategory.text!)
                category = arrVBCategoryId[index!]
            }
        }else{
            txtVisionCategory.placeholder = "Select Category"
            txtVisionCategory.text = ""
        }
        
        
        imageArray = []
        self.arrVBImageId = []
        let imgUrlPath = data["filePath"] as? String ?? ""
        let arrimgUrl = data["vboardAttachment"] as! [AnyObject]
        if arrimgUrl.count > 0 {
            for obj in arrimgUrl {
                let imgUrl = obj["vbAttachmentFile"] as? String ?? ""
                
                if imgUrl != "" {
                    let url = URL(string: imgUrlPath+"\(userID)/"+imgUrl)
                    if let data = try? Data(contentsOf: url!) {
                        self.imageArray.append(UIImage(data: data)!)
                        self.arrVBImageId.append(obj["vbAttachmentId"] as? String ?? "")
                    }
                }
            }
        }
        self.pagerView.reloadData()
        OBJCOM.hideLoader()
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        NotificationCenter.default.post(name: Notification.Name("UpdateVB"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionUpdate(_ sender:UIButton){
        
        
        if isValidate() == true {
            if arrVBCategoryTitle.contains(txtVisionCategory.text!) {
                let index = arrVBCategoryTitle.index(of:txtVisionCategory.text!)
                category = arrVBCategoryId[index!]
            }
            if OBJCOM.isConnectedToNetwork(){
                OBJCOM.setLoader()
                self.updateVisionBoard()
            }else{
                OBJCOM.NoInternetConnectionCall()
            }
        }
    }
    
    @IBAction func actionUploadPicture(_ sender:UIButton){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionGallary = UIAlertAction(title: "Gallary & Camera", style: .default)
        {
            UIAlertAction in
          
            let cameraViewController = CameraViewController { [weak self] image, asset in
                DispatchQueue.main.async(execute: {
                    if let image = image {
                        self?.imageArray.append(image)
                        
                        if let data = UIImageJPEGRepresentation(image, 0.6) {
                            if OBJCOM.isConnectedToNetwork(){
                                OBJCOM.setLoader()
                                self?.uploadVBImages(data, filename: "vb_\(userID)_\(self?.vbId ?? "")_\(Date()).jpg", vbId: self?.vbId ?? "")
                            }else{
                                OBJCOM.NoInternetConnectionCall()
                            }
                            
                           //
                        }
                        self?.pagerView.reloadData()
                    }
                })
                self?.dismiss(animated: true, completion: nil)
            }
            
            self.present(cameraViewController, animated: true, completion: nil)
            
        }
        actionGallary.setValue(UIColor.black, forKey: "titleTextColor")
      
        let actionSavedDocs = UIAlertAction(title: "From Saved Documents", style: .default)
        {
            UIAlertAction in
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(self.addFilesFromDocuments),
                name: NSNotification.Name(rawValue: "EDITVBFILES"),
                object: nil)
            
            let storyboard = UIStoryboard(name: "VisionBoard", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "idSavedDocListVC") as! SavedDocListVC
            vc.className = "EditVB"
            vc.modalPresentationStyle = .custom
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: false, completion: nil)
        }
        actionSavedDocs.setValue(UIColor.black, forKey: "titleTextColor")
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        
        //alert.addAction(actionCamera)
        alert.addAction(actionGallary)
        alert.addAction(actionSavedDocs)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension DetailsVB : UITextFieldDelegate {
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.imageArray.count;
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        if pagerView == pagerView {
            cell.imageView?.image = imageArray[index]
            cell.btnDelete?.setImage(#imageLiteral(resourceName: "ic_close_orange"), for: .normal)
            cell.btnDelete?.addTarget(self, action: #selector(deleteImage), for: .touchUpInside)
            cell.btnDelete?.tag = index
        }
        return cell
    }
    
    public func pagerView (_ pagerView: FSPagerView, didSelectItemAt index: Int){
     
    }
    
    @objc func deleteImage(sender : UIButton){
        UIView.animate(withDuration: 0.2, animations: {
            if self.imageArray.count > 0 {
                self.imageArray.remove(at: sender.tag)
                print(self.arrVBImageId[sender.tag])
                if OBJCOM.isConnectedToNetwork(){
                    OBJCOM.setLoader()
                    self.deleteVisionAttachment(attachmentId: self.arrVBImageId[sender.tag])
                }else{
                    OBJCOM.NoInternetConnectionCall()
                }
                self.pagerView.reloadData()
            }
        })
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtVisionCategory {
            self.selectCategoryOptions()
            return false
        }
        return true
    }
    
    func selectCategoryOptions() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for i in 0 ..< arrVBCategoryTitle.count {
            let action = UIAlertAction (title: arrVBCategoryTitle[i], style: .default)
            {
                UIAlertAction in
                category = arrVBCategoryId[i]
                self.txtVisionCategory.text = arrVBCategoryTitle[i]
            }
            action.setValue(UIColor.black, forKey: "titleTextColor")
            alert.addAction(action)
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
        {
            UIAlertAction in
        }
        actionCancel.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getVisionBoardCategory(){
        
        let dictParam = ["userId": userID,
                         "platform":"3"]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "getVisionBoardCategory", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as! [AnyObject]
                for obj in result {
                    arrVBCategoryTitle.append(obj.value(forKey: "vbCategory") as! String)
                    arrVBCategoryId.append(obj.value(forKey: "vbCategoryId") as! String)
                }
               // OBJCOM.hideLoader()
            }else{
                
                OBJCOM.setAlert(_title: "", message: "Cannot get response..")
                OBJCOM.hideLoader()
            }
        };
    }
}

extension DetailsVB {
    
    func deleteVisionAttachment(attachmentId:String) {
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "attachmentId" :attachmentId]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "deleteVisionAttachment", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as? String ?? ""
                OBJCOM.setAlert(_title: "", message: "Image removed successfully.")
                OBJCOM.hideLoader()
            }else{
                
                OBJCOM.setAlert(_title: "", message: "Cannot get response..")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func updateVisionBoard() {
        let dictParam = ["userId":userID,
                         "platform":"3",
                         "vboardId" : vbId,
                         "vboardTitle":self.txtVisionTitle.text!,
                         "vboardDescription":self.txtVisionDesc.text!,
                         "vboardEmotion":self.txtVisionDesc2.text!,
                         "vboardCategoryId":category] as [String : String]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        let dictParamTemp = ["param":jsonString];
        
        typealias JSONDictionary = [String:Any]
        OBJCOM.modalAPICall(Action: "editVisionBoard", param:dictParamTemp as [String : AnyObject],  vcObject: self){
            JsonDict, staus in
            let success:String = JsonDict!["IsSuccess"] as! String
            if success == "true"{
                let result = JsonDict!["result"] as? String ?? ""
                let vbId = JsonDict!["vBoardId"] as? String ?? ""
                OBJCOM.setAlert(_title: "", message: result)
//                if self.imageArray.count > 0 {
//                    for i in 0 ..< self.imageArray.count {
//                        if let data = UIImageJPEGRepresentation(self.imageArray[i], 0.6) {
//                            DispatchQueue.main.async {
//                                self.uploadVBImages(data, filename: "vb_\(userID)_\(vbId)_\(i).jpg", vbId: vbId)
//                            }
//                        }
//                    }
//                }
                
                NotificationCenter.default.post(name: Notification.Name("UpdateVB"), object: nil)
                OBJCOM.hideLoader()
                self.dismiss(animated: true, completion: nil)
            }else{
                
                OBJCOM.setAlert(_title: "", message: "Cannot get response..")
                OBJCOM.hideLoader()
            }
        };
    }
    
    func isValidate() -> Bool {
        if txtVisionTitle.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please enter title.")
            return false
        }else if txtVisionCategory.text == "" {
            OBJCOM.setAlert(_title: "", message: "Please set category.")
            return false
        }else if self.imageArray.count == 0 {
            OBJCOM.setAlert(_title: "", message: "Please set vision picture.")
            return false
        }
        return true
    }
    
    
    func uploadVBImages(_ file: Data,filename : String, vbId:String) {
        
        let parameters = ["userId" : userID,
                          "platform":"3",
                          "vboardId":vbId ]
        let fileData = file
        let URL2 = try! URLRequest(url: "\(SITEURL)/uploadVisionAttachment", method: .post, headers: ["Content-Type":"application/x-www-form-urlencoded"])
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(fileData as Data, withName: "upload", fileName: filename, mimeType: "text/plain")
            
            for (key, value) in parameters {
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
        }, with: URL2 , encodingCompletion: { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.responseJSON {
                    response in
                    if let JsonDict = response.result.value as? [String : Any]{
                        print(JsonDict)
                        let success:String = JsonDict["IsSuccess"] as! String
                        if success == "true"{
                            OBJCOM.hideLoader()
                            let result = JsonDict["result"] as! [String:Any]
                            self.arrVBImageId.append(result["vbAttachmentId"] as? String ?? "")
                            
                            OBJCOM.setAlert(_title: "", message: "Image uploaded successfully.")
                        }else{
                            let result = JsonDict["result"] as! String
                            OBJCOM.setAlert(_title: "", message: result)
                            OBJCOM.hideLoader()
                        }
                    }
                }
            case .failure(_):
                OBJCOM.setAlert(_title: "", message: "Failed to upload image.")
                break
            }
        })
    }
    
    @objc func addFilesFromDocuments(notification: NSNotification){
        print(notification.object!)
        let fileData = notification.object as! [AnyObject]
        if fileData.count > 0 {
            for obj in fileData {
               // let fileOri = obj["fileOri"] as? String ?? ""
                let filePath = obj["filePath"] as? String ?? ""
                
                let url = URL(string: "\(filePath)")
                if let data = try? Data(contentsOf: url!) {
                    self.imageArray.append(UIImage(data: data)!)
                    if OBJCOM.isConnectedToNetwork(){
                        OBJCOM.setLoader()
                        self.uploadVBImages(data, filename: "vb_\(userID)_\(self.vbId)_\(Date()).jpg", vbId: self.vbId)
                    }else{
                        OBJCOM.NoInternetConnectionCall()
                    }
                    self.pagerView.reloadData()
                }
            }
        }
        
    }
}
