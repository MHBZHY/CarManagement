//
//  UserTypeTableViewCell.swift
//  CarManagement
//
//  Created by zhy on 16/4/16.
//  Copyright © 2016年 随便. All rights reserved.
//

import UIKit


protocol TypeButtons {
	func typeButtonsDidTapped(btn: UIButton)
}


class UserTypeTableViewCell: UITableViewCell {
	
	var buttons = [UIButton(type: .Custom), UIButton(type: .Custom)]
	
	var texts = [String]()
	var images = [String?]()
	

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

	func setViewsWithSize(size: CGSize) -> Void {
		//一排按钮
		var buttonWidth = [CGFloat]()
		let imageWidth = SCREEN_WIDTH * 0.1
		var allWidth: CGFloat = 0
		
		for i in 0 ..< buttons.count {
			buttons[i].tag = i
			
			//设置button图片
			buttons[i].setImage(UIImage(named: images[i]!)!, forState: .Normal)
			buttons[i].imageView!.frame = CGRectMake(0, 0, imageWidth, imageWidth)
			
			//设置button title
			buttons[i].setTitle(texts[i], forState: .Normal)
			buttons[i].setTitleColor(UIColor.blackColor(), forState: .Normal)
			buttons[i].titleLabel!.font = UIFont.systemFontOfSize(12)
			buttons[i].titleLabel!.sizeToFit()
			
			buttonWidth.append(
				(imageWidth > buttons[i].titleLabel!.frame.width) ? imageWidth : buttons[i].titleLabel!.frame.width
			)
			
			//设置button frame
			buttons[i].frame = CGRectMake(
				0,
				(size.height - buttonWidth[i] - 12) / 2,
				buttonWidth[i],
				buttonWidth[i] + 12
			)
			
			//button title 偏移
			buttons[i].titleEdgeInsets = UIEdgeInsetsMake(imageWidth, -imageWidth, 0, 0)
			buttons[i].imageEdgeInsets = UIEdgeInsetsMake(0, (buttonWidth[i] - imageWidth) / 2, 12, (buttonWidth[i] - imageWidth) / 2)
			
			
			//计算总长
			allWidth += buttonWidth[i]
			if i > 0 {
				buttonWidth[i] += buttonWidth[i - 1]
			}
		}
		
		for i in 0 ..< buttons.count {
			var btnX: CGFloat {
				if i > 0 {
					return ((SCREEN_WIDTH - allWidth) / CGFloat(buttons.count + 1)) * CGFloat(i + 1) + buttonWidth[i - 1]
				}
				else {
					return ((SCREEN_WIDTH - allWidth) / CGFloat(buttons.count + 1)) * CGFloat(i + 1)
				}
			}
			
			buttons[i].frame = CGRectMake(
				btnX,
				buttons[i].frame.minY,
				buttons[i].frame.width,
				buttons[i].frame.height
			)
			
			//添加button到contentview
			self.contentView.addSubview(buttons[i])
		}
	}
}
