//
//  ReplyDetailsView.swift
//  SuccessEnSwift
//
//  Created by Milind Kudale on 15/02/19.
//  Copyright © 2019 milind.kudale. All rights reserved.
//

import UIKit

class ReplyDetailsView: UIViewController {

    @IBOutlet var lblUserName : UILabel!
    @IBOutlet var tblList : UITableView!
    
    var strUserName = ""
    var arrMessageDetails = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.designUI()
    }
    
    func designUI(){
        
        self.tblList.tableFooterView = UIView()
        self.tblList.rowHeight = UITableViewAutomaticDimension
        self.tblList.estimatedRowHeight = 50.0
        lblUserName.text = strUserName
        print(arrMessageDetails)
    }
    
    @IBAction func actionClose(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}
extension ReplyDetailsView : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return arrMessageDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblList.dequeueReusableCell(withIdentifier: "Cell") as! ReplyDetailCell
        
        let arrRepliedMessages : [String : AnyObject] = self.arrMessageDetails[indexPath.row] as! [String : AnyObject]
        print(arrRepliedMessages)
        if arrRepliedMessages.count > 0 {
            cell.lblDate.text = "\(arrRepliedMessages["replyDate"] as? String ?? "")"
            cell.lblMessage.text = "\(arrRepliedMessages["replyMessge"] as? String ?? "")"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
