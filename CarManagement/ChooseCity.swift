//
//  ChooseCity.swift
//  CarManagement
//
//  Created by zhy on 16/5/8.
//  Copyright © 2016年 随便. All rights reserved.
//

import Foundation
import SwiftyJSON


class ChooseCity: NSObject, UITableViewDataSource, UITableViewDelegate {
	private var _parentVC: MapViewController!
	var _tableView: UITableView!
	var _dataSource: JSON?
	
	
	init(target vc: UIViewController) {
        super.init()
		_parentVC = vc as! MapViewController
		
		_tableView = UITableView(frame: CGRectMake(
			0,
			vc.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height,
			SCREEN_WIDTH / 3,
			300),
		                         style: .Plain)
		
		_tableView.layer.cornerRadius = 6
		_tableView.layer.borderWidth = 0.5
		_tableView.layer.borderColor = UIColor ( red: 0.7556, green: 0.7556, blue: 0.7556, alpha: 1.0 ).CGColor
		_tableView.alpha = 0
		
		showTableView()
	}
    
	
	func showTableView() {
		_parentVC.view.addSubview(_tableView)
		
		UIView.animateWithDuration(0.3) { 
			self._tableView.alpha = 1
		}
	}
	
	
	//MARK: - tableView 代理
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if _dataSource == nil {
			return 0
		}
		else {
			return _dataSource!.count
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let identifier = "city"
		var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(identifier)
		
		if cell == nil {
			cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
		}
		
		cell!.textLabel?.text = _dataSource![indexPath.row].stringValue
		
		return cell!
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		//更改城市名称
		_parentVC._userCity = _dataSource![indexPath.row].stringValue
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		removeFromSuperView()
	}
	
	
	//MARK: - 附加函数
	func removeFromSuperView() {
		//渐变色
		UIView.animateWithDuration(0.3) {
			self._tableView.alpha = 0
		}
		
		//移除tableView
		CMTimer.scheduledTimerWithTimeInterval(0.3, userInfo: nil, repeats: false) { (timer) in
			self._tableView.removeFromSuperview()
		}
	}
}
