//
//  SPersonalLeaveNoteCell.swift
//  QJT
//
//  Created by LZQ on 16/4/28.
//  Copyright © 2016年 Hale. All rights reserved.
//

import UIKit

class SPersonalLeaveNoteCell: UITableViewCell {

    
    @IBOutlet weak var beginLbl: UILabel!
    @IBOutlet weak var endLbl: UILabel!
    @IBOutlet weak var teacherLbl: UILabel!
    @IBOutlet weak var stateLbl: UILabel!
    
    @IBOutlet weak var beginWeekLbl: UILabel!
    @IBOutlet weak var endWeekLbl: UILabel!
    
    
    var model: Leave! {
        didSet {
            beginLbl.text = model.fromTime.stringForDateFormat("yyyy-MM-dd")
            endLbl.text = model.toTime.stringForDateFormat("yyyy-MM-dd")
            teacherLbl.text = model.teacherName
            switch model.leaveState {
            case .Verify:
                stateLbl.textColor = UIColor(red: 255/255, green: 210/255, blue: 115/255, alpha: 1.0)
            case .Success:
                stateLbl.textColor = UIColor.qjtTintColor()
            case .Failed:
                stateLbl.textColor = UIColor(red: 255/255, green: 66/255, blue: 39/255, alpha: 1.0)
            default:
                stateLbl.textColor = UIColor.blackColor()
            }
            stateLbl.text = model.leaveState.toDescription()
            beginWeekLbl.text = model.fromTime.dateToWeek()
            endWeekLbl.text = model.toTime.dateToWeek()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func drawRect(rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetLineCap(context, CGLineCap.Round)
        CGContextSetLineWidth(context,1.0)
        CGContextSetAllowsAntialiasing(context, false)
        CGContextSetRGBStrokeColor(context,105/255, 105/255, 105/255, 1.0)
        CGContextBeginPath(context)
        
        CGContextMoveToPoint(context,100, rect.height / 2 )
        CGContextAddLineToPoint(context,UIScreen.mainScreen().bounds.width - 110, rect.height / 2)
   
        CGContextMoveToPoint(context, UIScreen.mainScreen().bounds.width - 120, rect.height / 2 - 5)
        CGContextAddLineToPoint(context,UIScreen.mainScreen().bounds.width - 110, rect.height / 2)
 
        CGContextMoveToPoint(context, UIScreen.mainScreen().bounds.width - 120, rect.height / 2 + 5)
        CGContextAddLineToPoint(context, UIScreen.mainScreen().bounds.width - 110, rect.height / 2)
        
        CGContextStrokePath(context)
        
    }

}
