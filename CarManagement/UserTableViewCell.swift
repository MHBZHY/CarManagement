//
//  UserTableViewCell.swift
//  CarManagement
//
//  Created by zhy on 16/4/16.
//  Copyright © 2016年 随便. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
	
	@IBOutlet weak var faceImageView: UIImageView!
	@IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		//背景图片
        let backImageView   = UIImageView(frame: self.frame)
        backImageView.image = UIImage(named: "Beach")
		
		self.contentView.addSubview(backImageView)

		
		//高斯模糊
        let blurView   = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        blurView.frame = self.frame
		
		self.contentView.addSubview(blurView)
		
		
		//置顶
		self.contentView.bringSubviewToFront(faceImageView)
		self.contentView.bringSubviewToFront(nameLabel)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}