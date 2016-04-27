//
//  LeaveCourseViewController.swift
//  QJT
//
//  Created by LZQ on 16/4/23.
//  Copyright © 2016年 Hale. All rights reserved.
//

import UIKit

protocol CourseViewDelegate {
    func refreshCourseData(courseDataArr: [CourseClass])
}

class LeaveCourseViewController: UIViewController {
    
    var courseView: CourseView!
    lazy var courseDataArr = [CourseClass]()
    lazy var refreshDataArr = [CourseClass]()
    var isCourseSelected: Bool = false
    var delegate: CourseViewDelegate?
    var index: Int = 0
    
    let weekExcelWidth: CGFloat = (UIScreen.mainScreen().bounds.width - 30) / 5
    let partExcelHeight: CGFloat = (UIScreen.mainScreen().bounds.height - 64 - 30) / 11
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        setupCourseBackground()
        asyncLoading()
        
    }
    
}

// MARK: - private Method
extension LeaveCourseViewController {
    
    func configUI() {
        navigationItem.title = "课程表"
    }
    
    func getNetwork() {
        self.pleaseWait()
        NetWorkManager.httpRequest(Methods.leave_studentGetCourseClasses, params: ["studentID":"2012812025"], modelType: CourseClass(), listType: CourseClass(), completed: { (responseData) in
            self.clearAllNotice()
            self.courseDataArr = responseData["list"] as! [CourseClass]
            self.configCourseExcel()
            
        }) { (errorMsg) in
            self.clearAllNotice()
            print(errorMsg!)
        }
    }
    
    func setupCourseBackground() {
        courseView = CourseView(frame: CGRect(x: 0, y: 64, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height - 64))
    }
    
    
    func asyncLoading() {
        //添加异步代码块到dispatch_get_global_queue队列
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            self.configCourseExcel()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.view.addSubview(self.courseView)
            self.getNetwork()
            })
        })
    }
    
    func configCourseExcel() {
        var i = 0
        for course in courseDataArr {
            let offsetX = 30 + CGFloat(course.week.toInt() - 1) * weekExcelWidth + 1
            let offsetY = 30 + CGFloat(course.fromSection - 1) * partExcelHeight + 1
            let courseLbl = HLable()
            let courseHook = UIImageView()
            courseLbl.verticalAlignment = .Middle
            courseLbl.frame = CGRectMake(offsetX, offsetY, weekExcelWidth - 2, partExcelHeight * CGFloat(course.durationSection) - 2)
            courseHook.frame = CGRectMake(weekExcelWidth - 19, courseLbl.bounds.height - 17, 15, 15)
            courseHook.image = UIImage(named: "course_hook")
            courseHook.tintColor = UIColor.qjtTintColor()
            courseHook.hidden = true
            courseLbl.text = course.courseName + "\n" + course.address + "\n" + course.teacherName
            courseLbl.backgroundColor = colorWithRandom()
            courseLbl.numberOfLines = 0
            courseLbl.font = UIFont.systemFontOfSize(14)
            courseLbl.layer.cornerRadius = 4
            courseLbl.layer.masksToBounds = true
            courseLbl.textColor = UIColor.whiteColor()
            courseLbl.tag = i + 1000
            let tap = UITapGestureRecognizer(target: self, action: #selector(LeaveCourseViewController.courseLblClicked(_:)))
            courseLbl.addGestureRecognizer(tap)
            courseLbl.userInteractionEnabled = true
            courseLbl.addSubview(courseHook)
            courseView.addSubview(courseLbl)
            i += 1
        }
    }
    
    func colorWithRandom() -> UIColor {
        let redNum = random() % 255
        let greenNum = random() % 255
        let blueNum = random() % 255
        if redNum < 200 || greenNum < 200 || blueNum < 200 {
            return UIColor(red: CGFloat(redNum)/255, green: CGFloat(greenNum)/255, blue: CGFloat(blueNum)/255, alpha: 0.7)
        } else {
            return colorWithRandom()
        }
    }
    
    func courseLblClicked(sender: UITapGestureRecognizer) {
        let courseLbl = sender.view as! HLable
        var hookImageView = UIImageView()
        let data = courseDataArr[sender.view!.tag - 1000]
        for hook in courseLbl.subviews {
            if hook is UIImageView {
                hookImageView = hook as! UIImageView
            }
        }
        if !courseLbl.isCourseSelected {
            courseLbl.layer.borderWidth = 2
            courseLbl.layer.borderColor = UIColor.qjtTintColor().CGColor
            courseLbl.isCourseSelected = true
            hookImageView.hidden = false
            refreshDataArr.append(data)
        } else {
            courseLbl.layer.borderWidth = 0
            courseLbl.isCourseSelected = false
            hookImageView.hidden = true
            for i in 0..<refreshDataArr.count {
                if (data.week == refreshDataArr[i].week) && (data.courseID == refreshDataArr[i].courseID) {
                    refreshDataArr.removeAtIndex(i)
                    break
                }
            }
        }
        delegate?.refreshCourseData(refreshDataArr)
        
    }
}