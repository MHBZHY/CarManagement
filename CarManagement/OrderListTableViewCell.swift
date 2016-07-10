//
//  OrderListTableViewCell.swift
//  CarManagement
//
//  Created by zhy on 16/5/22.
//  Copyright © 2016年 随便. All rights reserved.
//

import UIKit

class OrderListTableViewCell: UITableViewCell {
    
    var timeLabel: UILabel!
    var addressLabel: UILabel!
    var priceLabel: UILabel!
    

    class func initWithSize(size: CGSize, tableView: UITableView, reuseIdentifier: String?, setTextBeforeSetFrame action: (OrderListTableViewCell) -> Void) -> OrderListTableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier!) as? OrderListTableViewCell
        
        if cell == nil {
            cell = OrderListTableViewCell(style: .Default, reuseIdentifier: reuseIdentifier)
        }
        
        cell!.accessoryType = .DisclosureIndicator
        
        action(cell!)
        cell!.setFrameWithSize(size)
        
        return cell!
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        timeLabel      = UILabel()
//        _timeLabel.font = UIFont.boldSystemFontOfSize(18)
        timeLabel.textColor = UIColor.blackColor()
        
        addressLabel           = UILabel()
//        _addressLabel.font      = UIFont.systemFontOfSize(12)
        addressLabel.textColor = UIColor.lightGrayColor()
        
        priceLabel           = UILabel()
//        _priceLabel.font      = UIFont.systemFontOfSize(16)
        priceLabel.textColor = UIColor.grayColor()
        
        
        contentView.addSubview(timeLabel)
        contentView.addSubview(addressLabel)
        contentView.addSubview(priceLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setFrameWithSize(size: CGSize) {
        let top: CGFloat = size.height * 0.1
        let X: CGFloat   = 16
        
//        let space: CGFloat = size.height * 0.2
        
        timeLabel.frame = CGRectMake(X, top, SCREEN_WIDTH / 2, size.height * 0.3)
        timeLabel.font  = UIFont.boldSystemFontOfSize(timeLabel.frame.height)
        
        addressLabel.frame = CGRectMake(X, size.height * (1 - 0.2) - top, SCREEN_WIDTH, size.height * 0.2)
        addressLabel.font  = UIFont.systemFontOfSize(addressLabel.frame.height)
        
        priceLabel.font  = UIFont.systemFontOfSize(size.height * 0.3)
        let priceSize    = (priceLabel.text! as NSString).sizeWithAttributes([NSFontAttributeName: priceLabel.font])
        priceLabel.frame = CGRectMake(contentView.frame.width - priceSize.width, (size.height - priceSize.height) / 2, priceSize.width, priceSize.height)
    }
}

