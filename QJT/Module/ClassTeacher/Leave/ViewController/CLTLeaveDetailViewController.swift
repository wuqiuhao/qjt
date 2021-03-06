//
//  CLTLeaveDetailViewController.swift
//  QJT
//
//  Created by LZQ on 16/5/1.
//  Copyright © 2016年 Hale. All rights reserved.
//

import UIKit

class CLTLeaveDetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var verifyBtn: UIButton!
    
    var dataArr = [Dictionary<String, String>]()
    var leave: Leave!
    var leaveCourseArr = [LeaveDetail]()
    var courseStr = ""
    var reason = ""
    var isHistory = false
    var leaveID: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        setupBtn()
        perpareData()
        getNetWorkData()
    }
}

// MARK: - private Method
extension CLTLeaveDetailViewController {
    func configUI() {
        tableView.estimatedRowHeight = 100
        self.automaticallyAdjustsScrollViewInsets = false
        verifyBtn.hidden = isHistory
        navigationItem.title = "请假单"
    }
    
    func perpareData() {
        let data = ["title":"审核状态:","detail":"请选择","flag":"0"]
        dataArr.append(data)
    }
    
    func getNetWorkData() {
        NetWorkManager.httpRequest(Methods.leave_getLeaveDetailByLeaveID, params: ["leaveID":leaveID,"userType":UserType.Teacher.rawValue], modelType: Leave(), listType: LeaveDetail(), completed: { (responseData) in
            self.leaveCourseArr = responseData["list"] as! [LeaveDetail]
            self.leave = responseData["model"] as! Leave
            var i = 0
            for data in self.leaveCourseArr {
                if i != self.leaveCourseArr.count - 1 {
                    self.courseStr = self.courseStr + data.courseName + " " + data.address + "\n"
                } else {
                    self.courseStr = self.courseStr + data.courseName + " " + data.address
                }
                i += 1
            }
            self.tableView.reloadData()
        }) { [weak self](errorMsg) in
            self?.errorNotice(errorMsg!)
        }

    }
    
    func setupBtn() {
        verifyBtn.layer.cornerRadius = 4
        verifyBtn.clipsToBounds = true
        verifyBtn.addTarget(self, action: #selector(CLTLeaveDetailViewController.verifyBtnClicked), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func verifyBtnClicked() {
        if dataArr.count == 1 {
            if dataArr[0]["flag"] == "0" {
                self.errorNotice("请选择审核状态")
                return
            }
        } else if dataArr.count == 2 {
            if dataArr[0]["flag"] == "0" {
                self.errorNotice("请选择审核状态")
                return
            }
            if dataArr[1]["flag"] == "0" {
                self.errorNotice("请填写拒绝原因")
                return
            }
        }
        var params = [String:AnyObject]()
        params.updateValue(leave.leaveID, forKey: "leaveID")
        params.updateValue(reason, forKey: "refuseReason")
        params.updateValue(leave.studentID, forKey: "studentID")
        if dataArr[0]["detail"] == "通过" {
            params.updateValue(2, forKey: "leaveState")
        } else if dataArr[0]["detail"] == "不通过" {
            params.updateValue(3, forKey: "leaveState")
            if reason == "" {
                
            }
        }
        self.pleaseWait()
        NetWorkManager.httpRequest(Methods.leave_checkApplication, params: params, modelType: EmptyModel(), listType: EmptyModel(), completed: { (responseData) in
            self.clearAllNotice()
            NSNotificationCenter.defaultCenter().postNotificationName("refreshLeave", object: nil)
            self.navigationController?.popViewControllerAnimated(true)
            }) { [weak self] (errorMsg) in
                self?.clearAllNotice()
                self?.errorNotice(errorMsg!)
        }
    }
}

// MARK: - UITableViewDelegate
extension CLTLeaveDetailViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 4 && !isHistory {
            let alertVC = UIAlertController(title: "审核结果", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
            let passAction = UIAlertAction(title: "通过", style: UIAlertActionStyle.Cancel, handler: { (action) in
                self.dataArr[0].updateValue("通过", forKey: "detail")
                self.dataArr[0].updateValue("1", forKey: "flag")
                if self.dataArr.count == 1 {
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 4, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
                } else if self.dataArr.count == 2 {
                    self.dataArr.removeAtIndex(1)
                    self.tableView.reloadData()
                }
                
            })
            let unPassAction = UIAlertAction(title: "不通过", style: UIAlertActionStyle.Destructive, handler: { (action) in
                self.dataArr[0].updateValue("不通过", forKey: "detail")
                self.dataArr[0].updateValue("1", forKey: "flag")
                if self.dataArr.count == 1 {
                    let reason = ["title":"拒绝原因:","detail":"请填写拒绝原因","flag":"0"]
                    self.dataArr.append(reason)
                }
                self.tableView.reloadData()
            })
            alertVC.addAction(unPassAction)
            alertVC.addAction(passAction)
            self.presentViewController(alertVC, animated: true, completion: nil)
        } else if indexPath.row == 5 && !isHistory {
            let vc = UIStoryboard(name: "SLeave", bundle: nil).instantiateViewControllerWithIdentifier("LeaveReasonViewController") as! LeaveReasonViewController
            vc.delegate = self
            vc.textViewContent = reason
            vc.isLeave = false
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension CLTLeaveDetailViewController: ViewControllerTransmitDelegate {
    func transmitMessage(data: [AnyObject]) {
        if data.count != 0 && data[0] is String {
            if data[0] as? String != "" {
                dataArr[1]["detail"] = data[0] as? String
                dataArr[1]["flag"] = "1"
            } else {
                dataArr[1]["detail"] = "请填写拒绝原因"
                dataArr[1]["flag"] = "0"
            }
            reason = dataArr[1]["detail"]!
            tableView.reloadData()
            
        }
    }
}

// MARK: - UITableViewDataSource
private let cellIdeitiferForDetail = "CLTLeaveDetailCell"
extension CLTLeaveDetailViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let _ = leave {
            if leave.leaveState == .Failed {
                return 5 + dataArr.count
            } else {
                return 4 + dataArr.count
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdeitiferForDetail, forIndexPath: indexPath) as! CLTLeaveDetailCell
        switch indexPath.row {
        case 0:
            cell.titleLbl.text = "请假时间:"
            cell.detailLbl.text = leave.fromTime.stringForDateFormat("yyyy.MM.dd") + " - " + leave.toTime.stringForDateFormat("yyyy.MM.dd")
        case 1:
            cell.titleLbl.text = "请假学生:"
            cell.detailLbl.text = leave.studentName
        case 2:
            cell.titleLbl.text = "请假课程:"
            cell.detailLbl.text = courseStr
        case 3:
            cell.titleLbl.text = "请假原因:"
            cell.detailLbl.text = leave.reason
        case 4:
            if !isHistory {
                cell.titleLbl.text = dataArr[0]["title"]
                cell.detailLbl.text = dataArr[0]["detail"]
            } else {
                cell.titleLbl.text = "审核状态:"
                cell.detailLbl.text = leave.leaveState.toDescription()
            }
        case 5:
            if !isHistory {
                cell.titleLbl.text = dataArr[1]["title"]
                cell.detailLbl.text = dataArr[1]["detail"]
            } else {
                cell.titleLbl.text = "拒绝原因:"
                cell.detailLbl.text = leave.refuseReason
            }

        default:
            return UITableViewCell()
        }
        return cell
    }
}