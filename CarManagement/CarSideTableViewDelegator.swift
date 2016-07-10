//
//  CarSideTableViewDelegator.swift
//  CarManagement
//
//  Created by zhy on 16/5/18.
//  Copyright © 2016年 随便. All rights reserved.
//

import UIKit

class CarSideTableViewDelegator: NSObject, UITableViewDelegate, UITableViewDataSource {
	var _tableView: UITableView!
	var _parentVC: CarViewController!
	var _dataSource: [String]!
	var _pageCtrl: UIPageControl!
	
	
	init(target vc: CarViewController, delegateForTableView view: UITableView, dataSource: [String]) {
        _parentVC   = vc
        _tableView  = view
        _dataSource = dataSource
        _pageCtrl   = vc._pageCtrl
	}
	
	
	//MARK: - tableview代理与数据源
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return _dataSource.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let identifier = "carname"
		var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(identifier)
		
		if cell == nil {
			cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
		}
		
		cell!.textLabel?.text = _dataSource[indexPath.row]
		cell!.textLabel?.textColor = UIColor.blackColor()
		
		return cell!
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		//换页
		_pageCtrl.currentPage = indexPath.row
		
		//scrollView动画翻到指定页
		UIView.animateWithDuration(0.3) { 
			self._parentVC._scrollView.contentOffset.x = CGFloat(self._pageCtrl.currentPage) * SCREEN_WIDTH
		}
		
		//延时刷新主tableView
		CMTimer.scheduledTimerWithTimeInterval(0.3, userInfo: nil, repeats: false) { (timer) in
			self._parentVC.updateDataSource(self._pageCtrl.currentPage, callBack: { 
				self._parentVC._tableView.reloadData()
			})
		}
		
		//点击动画
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		//隐藏sideTableView
		_parentVC._isSideViewShown = false
	}
}
