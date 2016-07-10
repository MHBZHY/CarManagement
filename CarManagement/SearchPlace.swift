//
//  SearchPlace.swift
//  CarManagement
//
//  Created by zhy on 16/5/8.
//  Copyright © 2016年 随便. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire


class SearchPlace: NSObject, UITableViewDelegate, UITableViewDataSource, BMKGeoCodeSearchDelegate, BMKRouteSearchDelegate {
	
	var _tableView: UITableView!
	var _parentVC: UIViewController!
	var _mapView: BMKMapView!
	
	var _cancelButton: CMButton?				//搜索框旁的取消按钮
	var _isSearching = false					//搜索框是否被激活
	var _searchTextField: UITextField!		//搜索地点
	var _placeArray: [JSON]?					//搜索产生的候选词数组
	var _userCity: String!					//用户所在城市
	var _geocoder: BMKGeoCodeSearch!			//地址解析器
	var _startAnnotation: BMKPointAnnotation?		//起始位置
	var _endAnnotation: BMKPointAnnotation?			//终点位置
	var _routeSearch: BMKRouteSearch?		//路径规划器
	var _routeSearchStartButton: UIButton?	//启动路径规划
	
	var _isRouteSearching = false		//是否正在路径规划中
	
	
	
	//MARK: - 初始化
	init(target vc: UIViewController, userInCity city: String, searchTextField textField: UITextField) {
        _parentVC        = vc
        _userCity        = city
        _geocoder        = BMKGeoCodeSearch()
        _searchTextField = textField
        _mapView         = (_parentVC as! MapViewController)._mapView
		
		//路径搜索按钮
		_routeSearchStartButton = UIButton(type: .Custom)
		
		_routeSearchStartButton!.frame = CGRectMake(
			(SCREEN_WIDTH - 30) / 2,
			_parentVC.view.frame.height - _parentVC.tabBarController!.tabBar.frame.height - 30 - 8,
			30,
			30)
        _routeSearchStartButton!.layer.cornerRadius = 6
        _routeSearchStartButton!.layer.borderWidth  = 0.5
        _routeSearchStartButton!.layer.borderColor  = UIColor ( red: 0.7556, green: 0.7556, blue: 0.7556, alpha: 1.0 ).CGColor
		_routeSearchStartButton!.setTitle("R", forState: .Normal)
        _routeSearchStartButton!.titleLabel?.font   = UIFont.systemFontOfSize(15)
	}
    
	func startSearching() {
		_geocoder.delegate = self
		
		//监听搜索框文本变化
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(searchTextFieldTextDidChanged(_:)), name: UITextFieldTextDidChangeNotification, object: nil)
		
		
		if _isSearching == false {
			//初始化显示结果用tableView
			_tableView = UITableView(frame: _parentVC.view.frame, style: .Plain)
			
			_tableView!.contentInset = UIEdgeInsetsMake(
				_parentVC.navigationController!.navigationBar.frame.height + UIApplication.sharedApplication().statusBarFrame.height,
				0,
				_parentVC.tabBarController!.tabBar.frame.height,
				0)
			
			_tableView!.delegate   = self
			_tableView!.dataSource = self
			_tableView!.alpha      = 0
			
			_parentVC.view.addSubview(self._tableView!)
			
			//渐变显示tableView
			UIView.animateWithDuration(0.3) {
				//文本框变短
				self._searchTextField.frame = CGRectMake(
					self._searchTextField.frame.minX,
					self._searchTextField.frame.minY,
					self._searchTextField.frame.width - 38,
					self._searchTextField.frame.height)
				
				//显示tableView
				self._tableView!.alpha = 1
			}
			
			
			//取消按钮
			self._cancelButton = CMButton(type: .Custom)
			
			self._cancelButton!.frame = CGRectMake(self._searchTextField.frame.maxX + 8, self._searchTextField.frame.minY, 30, 30)
			self._cancelButton!.setTitle("取消", forState: .Normal)
			self._cancelButton!.setTitleColor(UIColor ( red: 0.2031, green: 0.3677, blue: 0.9483, alpha: 1.0 ), forState: .Normal)
			self._cancelButton!.titleLabel!.font = UIFont.systemFontOfSize(15)
			
			self._cancelButton!.addTarget(forControlEvents: .TouchUpInside, responseAction: {
				//MARK: - 取消按钮事件
				//恢复原长
				UIView.animateWithDuration(0.3, animations: {
					self.searchFieldExitFromEditing()
				})
			})
			
			//延时显示取消按钮
			CMTimer.scheduledTimerWithTimeInterval(0.3, userInfo: nil, repeats: false, completionHandler: { (timer) in
				self._parentVC.navigationController!.navigationBar.addSubview(self._cancelButton!)
			})
			
			//进入搜索模式
			_isSearching = true
		}
	}
	
	
	//MARK: - 搜索框退出编辑模式
	func searchFieldExitFromEditing() {
		_tableView!.removeFromSuperview()
		
		_cancelButton!.removeFromSuperview()
		
		self._searchTextField.frame = CGRectMake(
			self._searchTextField.frame.minX,
			self._searchTextField.frame.minY,
			self._searchTextField.frame.width + 38,
			self._searchTextField.frame.height)
		
		_searchTextField.resignFirstResponder()
		
		
		//退出编辑模式
		_isSearching = false
	}
	
	
	//文本变化
	func searchTextFieldTextDidChanged(notification: NSNotification) {
		//发送查询请求
		request(.GET, "http://api.map.baidu.com/place/v2/suggestion",
			parameters: ["query": _searchTextField.text!,
						"region": _userCity!,
						"output": "json",
							"ak": AK_IOS,
						 "mcode": BUNDLE_IDENTIFIER],
			encoding: .URLEncodedInURL, headers: nil)
			.responseJSON { (res) in
				if res.result.isSuccess {
					if res.result.value != nil {
						let json = JSON(res.result.value!)
						//						print(json)
						
						self._placeArray = json["result"].arrayValue
						
						self._tableView!.reloadData()
					}
				}
				else {
					print(res.request?.URLString)
					print(res.result.error)
				}
		}
	}
	
	
	//MARK: - tableView代理
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if _placeArray == nil {
			return 0
		}
		else {
			return _placeArray!.count
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let identifier = "result"
		var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(identifier)
		
		if cell == nil {
			cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
		}
		
		cell!.textLabel?.text = _placeArray![indexPath.row]["name"].stringValue
		
		return cell!
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		//解析选中地址
		let geocodeOption = BMKGeoCodeSearchOption()
		
		geocodeOption.city = _userCity!
		geocodeOption.address = _placeArray![indexPath.row]["name"].stringValue
		
		if _geocoder.geoCode(geocodeOption) {
			print("查询成功")
		}
		else {
			print("查询失败")
		}
		
		//点击动画
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		
		//退出编辑状态
		searchFieldExitFromEditing()
	}
	
	func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		_searchTextField.resignFirstResponder()
	}

	
	//MARK: - 地址解析代理
	func onGetGeoCodeResult(searcher: BMKGeoCodeSearch!, result: BMKGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
//		(_parentVC as! MapViewController)._mapView.removeAnnotation(<#T##annotation: BMKAnnotation!##BMKAnnotation!#>)
		
		//添加大头针
		let annotation = BMKPointAnnotation()
		
        annotation.coordinate = result.location
        annotation.title      = result.address
		
		_mapView.addAnnotation(annotation)//添加
		_mapView.selectAnnotation(annotation, animated: true)//选中
		_mapView.centerCoordinate = annotation.coordinate//转至中心
	}
	
	func onGetReverseGeoCodeResult(searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
		
	}
	
	
	//MARK: - 路径规划代理方法
	func onGetDrivingRouteResult(searcher: BMKRouteSearch!, result: BMKDrivingRouteResult!, errorCode error: BMKSearchErrorCode) {
		
		_mapView.removeAnnotations(_mapView.annotations)
		_mapView.removeOverlays(_mapView.overlays)
		
		if error == BMK_SEARCH_NO_ERROR {
			let plan = result.routes[0] as! BMKDrivingRouteLine
			
			let size = plan.steps.count
			var planPointCounts = 0
			for i in 0..<size {
				let transitStep = plan.steps[i] as! BMKDrivingStep
				if i == 0 {
					let item = RouteAnnotation()
					item.coordinate = plan.starting.location
					item.title = "起点"
					item.type = 0
					_mapView.addAnnotation(item)  // 添加起点标注
				}else if i == size - 1 {
					let item = RouteAnnotation()
					item.coordinate = plan.terminal.location
					item.title = "终点"
					item.type = 1
					_mapView.addAnnotation(item)  // 添加终点标注
				}
				
				// 添加 annotation 节点
				let item = RouteAnnotation()
				item.coordinate = transitStep.entrace.location
				item.title = transitStep.instruction
				item.degree = Int(transitStep.direction) * 30
				item.type = 4
				_mapView.addAnnotation(item)
				
				// 轨迹点总数累计
				planPointCounts = Int(transitStep.pointsCount) + planPointCounts
			}
			
			// 添加途径点
			if plan.wayPoints != nil {
				for tempNode in plan.wayPoints as! [BMKPlanNode] {
					let item = RouteAnnotation()
					item.coordinate = tempNode.pt
					item.type = 5
					item.title = tempNode.name
					_mapView.addAnnotation(item)
				}
			}
			
			// 轨迹点
			var tempPoints = Array(count: planPointCounts, repeatedValue: BMKMapPoint(x: 0, y: 0))
			var i = 0
			for j in 0..<size {
				let transitStep = plan.steps[j] as! BMKDrivingStep
				for k in 0..<Int(transitStep.pointsCount) {
					tempPoints[i].x = transitStep.points[k].x
					tempPoints[i].y = transitStep.points[k].y
					i += 1
				}
			}
			
			// 通过 points 构建 BMKPolyline
			let polyLine = BMKPolyline(points: &tempPoints, count: UInt(planPointCounts))
			// 添加路线 overlay
			_mapView.addOverlay(polyLine)
			mapViewFitPolyLine(polyLine)
		}
	}
	
	
	
	
	
	//MARK: - 路径规划
	//设置起始点
	func setStartPoint(annotationView view: BMKAnnotationView) {
		//初始化路径搜索
		if _routeSearch == nil {
			_routeSearch = BMKRouteSearch()
			
			_routeSearch!.delegate = self
		}
		
		
		//如果起点已存在
		if _startAnnotation != nil {
			_mapView.removeAnnotation(_startAnnotation)
		}
		
		
		//创建新大头针用于代替
		_startAnnotation = BMKPointAnnotation()
		
		_startAnnotation!.coordinate = view.annotation.coordinate
		_startAnnotation!.title = "起点：\(view.annotation.title!())"
		
		_mapView.removeAnnotation(view.annotation)
		_mapView.addAnnotation(_startAnnotation)
		_mapView.selectAnnotation(_startAnnotation, animated: true)
		
		
		//判断起点与终点是否全部指定
		if _startAnnotation != nil && _endAnnotation != nil {
			//路径规划启动按钮添加事件
			setStartRouteSearchButton()
			
			_routeSearchStartButton!.addTarget(self, action: #selector(startFindRoute), forControlEvents: .TouchUpInside)
			
			CMTimer.scheduledTimerWithTimeInterval(1, userInfo: nil, repeats: false, completionHandler: { (timer) in
				self._parentVC.view.addSubview(self._routeSearchStartButton!)
			})
		}
	}
	
	//设置终点
	func setEndPoint(annotationView view: BMKAnnotationView) {
		//初始化路径搜索
		if _routeSearch == nil {
			_routeSearch = BMKRouteSearch()
			
			_routeSearch!.delegate = self
		}
		
		
		//如果终点已存在
		if _endAnnotation != nil {
			_mapView.removeAnnotation(_endAnnotation)
		}
		
		
		//创建新大头针用于代替
		_endAnnotation = BMKPointAnnotation()
		
		_endAnnotation!.coordinate = view.annotation.coordinate
		_endAnnotation!.title = "终点：\(view.annotation.title!())"
		
		_mapView.removeAnnotation(view.annotation)
		_mapView.addAnnotation(_endAnnotation)
		_mapView.selectAnnotation(_endAnnotation, animated: true)
		
		
		//判断起点与终点是否全部指定
		if _startAnnotation != nil && _endAnnotation != nil {
			//路径规划启动按钮添加事件
			setStartRouteSearchButton()
			
			_routeSearchStartButton!.addTarget(self, action: #selector(startFindRoute), forControlEvents: .TouchUpInside)
			
			CMTimer.scheduledTimerWithTimeInterval(1, userInfo: nil, repeats: false, completionHandler: { (timer) in
				self._parentVC.view.addSubview(self._routeSearchStartButton!)
			})
		}
	}
	
	//启动路径规划
	func startFindRoute() {
		if _isRouteSearching {
			//清除所有覆盖物
			_mapView.removeOverlays(_mapView.overlays)
			_mapView.removeAnnotations(_mapView.annotations)
			
			//启用其余功能
			(_parentVC as! MapViewController).enableAllCapabilities(without: .FindRoute, .FollowMode)
			
			
			//切换状态
			_isRouteSearching = false
			
			//还原按钮状态
//			setStartRouteSearchButton()
			_routeSearchStartButton?.removeFromSuperview()
		}
		else {
			//创建起点
			let startNode = BMKPlanNode()
			//设置起点名称和坐标
			startNode.name = _startAnnotation!.title
			startNode.pt   = _startAnnotation!.coordinate
			
			//设置终点
			let endNode = BMKPlanNode()
			
			endNode.name = _endAnnotation!.title
			endNode.pt   = _endAnnotation!.coordinate
			
			
			//设置路径搜索信息
			let routeSearchOption = BMKDrivingRoutePlanOption()
			//设置起终点
            routeSearchOption.from = startNode
            routeSearchOption.to   = endNode
			//查询
			if _routeSearch!.drivingSearch(routeSearchOption) {
				print("路径信息规划成功")
			}
			else {
				ShowAlertWindow(target: _parentVC, alertTitle: "警告", message: "路径信息规划失败", actionTitle: "确定")
			}
			
			//查询期间禁用其他所有功能
			(_parentVC as! MapViewController).disableAllCapabilities(without: .FindRoute, .FollowMode)
			
			//切换状态
			_isRouteSearching = true
			
			//还原按钮状态
			setStartRouteSearchButton()
		}
	}
	
	//根据polyline设置地图范围
	func mapViewFitPolyLine(polyline: BMKPolyline!) {
		if polyline.pointCount < 1 {
			return
		}
		
		let pt = polyline.points[0]
		var ltX = pt.x
		var rbX = pt.x
		var ltY = pt.y
		var rbY = pt.y
		
		for i in 1..<polyline.pointCount {
			let pt = polyline.points[Int(i)]
			if pt.x < ltX {
				ltX = pt.x
			}
			if pt.x > rbX {
				rbX = pt.x
			}
			if pt.y > ltY {
				ltY = pt.y
			}
			if pt.y < rbY {
				rbY = pt.y
			}
		}
		
		let rect = BMKMapRectMake(ltX, ltY, rbX - ltX, rbY - ltY)
		_mapView.visibleMapRect = rect
		_mapView.zoomLevel = _mapView.zoomLevel - 0.3
	}
	
	
	//旋转图片
	func imageRotated(image: UIImage!, degrees: Int!) -> UIImage {
		let width = CGImageGetWidth(image.CGImage)
		let height = CGImageGetHeight(image.CGImage)
		let rotatedSize = CGSize(width: width, height: height)
		UIGraphicsBeginImageContext(rotatedSize);
		let bitmap = UIGraphicsGetCurrentContext();
		CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
		CGContextRotateCTM(bitmap, CGFloat(Double(degrees) * M_PI / 180.0));
		CGContextRotateCTM(bitmap, CGFloat(M_PI));
		CGContextScaleCTM(bitmap, -1.0, 1.0);
		CGContextDrawImage(bitmap, CGRectMake(-rotatedSize.width/2, -rotatedSize.height/2, rotatedSize.width, rotatedSize.height), image.CGImage);
		let newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		return newImage;
	}
	
	
	func getViewForRouteAnnotation(routeAnnotation: RouteAnnotation!) -> BMKAnnotationView? {
		var view: BMKAnnotationView?
		
		var imageName: String?
		switch routeAnnotation.type {
		case 0:
			imageName = "nav_start"
		case 1:
			imageName = "nav_end"
		case 2:
			imageName = "nav_bus"
		case 3:
			imageName = "nav_rail"
		case 4:
			imageName = "direction"
		case 5:
			imageName = "nav_waypoint"
		default:
			return nil
		}
		let identifier = "\(imageName)_annotation"
		view = _mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
		if view == nil {
			view = BMKAnnotationView(annotation: routeAnnotation, reuseIdentifier: identifier)
			view?.centerOffset = CGPointMake(0, -(view!.frame.size.height * 0.5))
			view?.canShowCallout = true
		}
		
		view?.annotation = routeAnnotation
		
		let bundlePath = NSBundle.mainBundle().resourcePath?.stringByAppendingString("/mapapi.bundle/")
		let bundle = NSBundle(path: bundlePath!)
		if let imagePath = bundle?.resourcePath?.stringByAppendingString("/images/icon_\(imageName!).png") {
			var image = UIImage(contentsOfFile: imagePath)
			if routeAnnotation.type == 4 {
				image = imageRotated(image, degrees: routeAnnotation.degree)
			}
			if image != nil {
				view?.image = image
			}
		}
		
		return view
	}

	
	
	//MARK: - 附加函数
	func setStartRouteSearchButton() {
		if _isRouteSearching {
			//进入搜索状态
			_routeSearchStartButton!.backgroundColor = UIColor ( red: 0.2031, green: 0.3677, blue: 0.9483, alpha: 1.0 )
			_routeSearchStartButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		}
		else {
			//退出搜索状态
			_routeSearchStartButton!.backgroundColor = UIColor.whiteColor()
			_routeSearchStartButton!.setTitleColor(UIColor ( red: 0.2031, green: 0.3677, blue: 0.9483, alpha: 1.0 ), forState: .Normal)
		}
	}
	
	
	func ifRemoveStartRouteSearchButton() {
		
	}
}