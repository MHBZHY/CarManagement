//
//  MapViewController.swift
//  CarManagement
//
//  Created by zhy on 16/4/11.
//  Copyright © 2016年 随便. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


enum Capabilities {
	case SearchField
	case FollowMode
	case ClearAnnos
	case FindRoute
}


class MapViewController: UIViewController, BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate {

	var _mapView: BMKMapView!
	var _locationService: BMKLocationService!
	
	var _chooseCityButton: UIButton!//选择城市
	var _searchTextField: UITextField!//搜索地点
	
	
	var _userFollowed = false						//是否跟踪用户
	@IBOutlet weak var _isFollowButton: UIButton!	//切换定位模式按钮
	@IBOutlet weak var _clearAnotationsButton: UIButton!
	var _geocoder: BMKGeoCodeSearch!					//地址解析器
	var _userCity: String?							//用户所在城市
	var _isChoosingCity = false						//选择城市tableView是否出现
	var _chooseCityClass: ChooseCity?				//选择城市辅助类
	var _searchPlaceClass: SearchPlace?				//搜索地点辅助类
	var _gasInfoClass: ShowGasStation!
	
	
	//MARK: - 加载后设定
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		//初始化地图
		_mapView = BMKMapView(frame: CGRectMake(
			0,
			self.view.frame.minY - UIApplication.sharedApplication().statusBarFrame.minY,
			SCREEN_WIDTH,
			SCREEN_HEIGHT))
		
		_mapView.delegate = self
		
		self.view.addSubview(_mapView)
		
		
		//初始化定位服务
        _locationService = BMKLocationService()
		
        _locationService.delegate  = self
		_locationService.distanceFilter = 100

		_locationService.startUserLocationService()
		
        _mapView.showsUserLocation = false//先关闭显示的定位图层
        _mapView.userTrackingMode  = BMKUserTrackingModeNone;//设置定位的状态
        _mapView.showsUserLocation = true//显示定位图层
		
		
		//初始化地址解析器
        _geocoder = BMKGeoCodeSearch()

        _geocoder.delegate = self
		
		
		//设置城市选择按钮
        _chooseCityButton = UIButton(type: .Custom)

		_chooseCityButton.frame = CGRectMake(8, 7, 0, 30)
		_chooseCityButton.setTitle(_userCity, forState: .Normal)
		_chooseCityButton.setTitleColor(UIColor ( red: 0.2031, green: 0.3677, blue: 0.9483, alpha: 1.0 ), forState: .Normal)
        _chooseCityButton.titleLabel?.font = UIFont.systemFontOfSize(15)
		_chooseCityButton.addTarget(self, action: #selector(chooseCityTapped(_:)), forControlEvents: .TouchUpInside)
		
		self.navigationController!.navigationBar.addSubview(_chooseCityButton)
		
		
		//设置搜索框
		//初始化
		_searchTextField = UITextField(frame: CGRectMake(_chooseCityButton.frame.maxX + 8, 7, SCREEN_WIDTH - _chooseCityButton.frame.maxX - 16, 30))
		
        _searchTextField.borderStyle     = .RoundedRect
        _searchTextField.clearButtonMode = .WhileEditing
        _searchTextField.placeholder     = "请在此处输入搜索内容..."
        _searchTextField.font            = UIFont.systemFontOfSize(14)
		
		//开始编辑触发事件
		_searchTextField.addTarget(self, action: #selector(searchTextFieldDidBeginEditing(_:)), forControlEvents: .EditingDidBegin)
		
		self.navigationController!.navigationBar.addSubview(_searchTextField)
		
		
		//跟随按钮设定
        _isFollowButton.backgroundColor    = UIColor.whiteColor()
        _isFollowButton.layer.cornerRadius = 6
        _isFollowButton.layer.borderWidth  = 0.5
        _isFollowButton.layer.borderColor  = UIColor ( red: 0.7556, green: 0.7556, blue: 0.7556, alpha: 1.0 ).CGColor
		
		self.view.bringSubviewToFront(_isFollowButton)//前置跟随按钮
		
		
		//清除大头针按钮设定
        _clearAnotationsButton.backgroundColor    = UIColor.whiteColor()
        _clearAnotationsButton.layer.cornerRadius = 6
        _clearAnotationsButton.layer.borderWidth  = 0.5
        _clearAnotationsButton.layer.borderColor  = UIColor ( red: 0.7556, green: 0.7556, blue: 0.7556, alpha: 1.0 ).CGColor
		
		self.view.bringSubviewToFront(_clearAnotationsButton)
		
		
		//初始化加油站辅助类
		_gasInfoClass = ShowGasStation()
    }
	
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		_searchTextField.alpha = 0
		_searchTextField.userInteractionEnabled = false
		
		_chooseCityButton.alpha = 0
		_chooseCityButton.userInteractionEnabled = false
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		UIApplication.sharedApplication().statusBarStyle = .Default
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		_searchTextField.alpha = 1
		_searchTextField.userInteractionEnabled = true
		
		_chooseCityButton.alpha = 1
		_chooseCityButton.userInteractionEnabled = true
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	//MARK: - 搜索框方法
	//开始编辑
	func searchTextFieldDidBeginEditing(sender: UITextField) {
		
		if _searchPlaceClass == nil {
			_searchPlaceClass = SearchPlace(target: self, userInCity: _userCity!, searchTextField: _searchTextField)
		}
		
		_searchPlaceClass!.startSearching()
	}
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		if segue.identifier == "ShowGasInfo" {
			let desVC = segue.destinationViewController as! GasInfoViewController
			
			desVC._json = (sender as! PackStruct).contentStruct as! JSON
		}
    }
	
	
	//MARK: - 定位方法
	func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
		_mapView.updateLocationData(userLocation)
		
		//定位更新后，若处于跟随模式，则显示周围加油站
		if _userFollowed {
			_gasInfoClass.getNearGasStation(withUserLocation: userLocation.location.coordinate, callBack: { (annotations) in
				self._mapView.removeAnnotations(self._gasInfoClass._gasAnnotations)
				self._gasInfoClass._gasAnnotations = annotations
				self._mapView.addAnnotations(self._gasInfoClass._gasAnnotations)
			})
		}
		
		//尚未获取当前城市
		if _userCity == nil {
			let revGeoSearchOption = BMKReverseGeoCodeOption()
			
			revGeoSearchOption.reverseGeoPoint = userLocation.location.coordinate
			
			//判断查询是否成功
			if _geocoder.reverseGeoCode(revGeoSearchOption) {
				print("解析成功")
			}
			else {
				print("解析失败")
			}
		}
	}
	
	//切换定位跟随方式
	@IBAction func followUser(sender: UIButton) {
		if _userFollowed == false {
			//开启用户跟随
            _mapView.userTrackingMode       = BMKUserTrackingModeFollow
            _isFollowButton.backgroundColor = UIColor ( red: 0.2031, green: 0.3677, blue: 0.9483, alpha: 1.0 )
			_isFollowButton.setTitle("F", forState: .Normal)
			_isFollowButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
			
			_userFollowed = true
			
			//显示附近加油站
			_gasInfoClass.getNearGasStation(withUserLocation: _mapView.centerCoordinate, callBack: { (annotations) in
				self._mapView.removeAnnotations(self._gasInfoClass._gasAnnotations)
				self._gasInfoClass._gasAnnotations = annotations
				self._mapView.addAnnotations(self._gasInfoClass._gasAnnotations)
			})
		}
		else {
            _mapView.userTrackingMode       = BMKUserTrackingModeNone
            _isFollowButton.backgroundColor = UIColor.whiteColor()
			_isFollowButton.setTitle("N", forState: .Normal)
			_isFollowButton.setTitleColor(UIColor ( red: 0.2031, green: 0.3677, blue: 0.9483, alpha: 1.0 ), forState: .Normal)
			
			_userFollowed = false
			
			//清除加油站
			_mapView.removeAnnotations(_gasInfoClass._gasAnnotations)
		}
	}
	
	
	//MARK: - 地址解析
	//正向解析
	func onGetGeoCodeResult(searcher: BMKGeoCodeSearch!, result: BMKGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
//		//添加大头针
//		let annotation = BMKPointAnnotation()
//		
//		annotation.coordinate = result.location
//		annotation.title = result.address
//		
//		_mapView.addAnnotation(annotation)
	}
	
	//反向解析
	func onGetReverseGeoCodeResult(searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
		if _userCity == nil && result.addressDetail.city != "" {
			_userCity = result.addressDetail.city
			
			_chooseCityButton.setTitle(_userCity, forState: .Normal)
			
            _chooseCityButton.frame = CGRectMake(8, 7, 15 * CGFloat((_userCity == nil) ? 0 : _userCity!.characters.count), 30)
            _searchTextField.frame  = CGRectMake(_chooseCityButton.frame.maxX + 8, 7, SCREEN_WIDTH - _chooseCityButton.frame.maxX - 16, 30)
		}
	}
	
	
	//MARK: - 地图方法
	//地图加载完毕
	func mapViewDidFinishLoading(mapView: BMKMapView!) {
		//跟随用户
		mapView.userTrackingMode = BMKUserTrackingModeFollow
		//锁放地图
		mapView.zoomLevel = 13
		//解除跟随状态
		mapView.userTrackingMode = BMKUserTrackingModeNone
	}
	
	
	//地图位置变化
	func mapView(mapView: BMKMapView!, regionDidChangeAnimated animated: Bool) {
		
	}
	
	//定制annotation view
	func mapView(mapView: BMKMapView!, annotationViewForBubble view: BMKAnnotationView!) {
		if view.annotation.subtitle?() == "加油站" {
			//设置加油站大头针view点击事件
//			let tap = CMTapGestureRecognizer.addTarget {
//				print(1)
//				self.performSegueWithIdentifier("ShowGasInfo",
//					sender: PackStruct(struct: self._gasInfoClass._gasInfo![self._gasInfoClass._gasAnnotations!.indexOf({ (anno) -> Bool in
//						view.annotation.isEqual(anno)
//					})!]))
//			}
//			
//			view!.addGestureRecognizer(tap)
			self.performSegueWithIdentifier("ShowGasInfo",
			                                sender: PackStruct(struct: self._gasInfoClass._gasInfo![self._gasInfoClass._gasAnnotations!.indexOf({ (anno) -> Bool in
												view.annotation.isEqual(anno)
											})!]))
		}
	}
	
	
	func mapView(mapView: BMKMapView!, viewForAnnotation annotation: BMKAnnotation!) -> BMKAnnotationView! {
		/**
		*根据anntation生成对应的View
		*@param mapView 地图View
		*@param annotation 指定的标注
		*@return 生成的标注View
		*/
		
		if annotation is RouteAnnotation {
			if let routeAnnotation = annotation as! RouteAnnotation? {
				return _searchPlaceClass!.getViewForRouteAnnotation(routeAnnotation)
			}
			
			return nil
		}
		else if annotation.subtitle?() == "加油站" {
			//加油站大头针
			let identifier = "gasPointer"
			var view = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as! BMKPinAnnotationView?
			
			if view == nil {
				view = BMKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
			}
			
			view!.pinColor     = UInt(BMKPinAnnotationColorGreen)//view颜色
			view!.animatesDrop = false//从天上掉下
			view!.draggable    = false//不可拖动
			view!.annotation   = annotation
			
			
			return view
		}
		else {
			let identifier = "pointer"
			var view = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as! BMKPinAnnotationView?
			
			if view == nil {
				view = BMKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
			}
			
			view!.pinColor     = UInt(BMKPinAnnotationColorRed)//view颜色
			view!.animatesDrop = true//从天上掉下
			view!.draggable    = false//不可拖动
			view!.annotation   = annotation
			
			
			let press = CMLongPressGestureRecognizer.addTarget {
				ShowActionSheet(target: self, andActions: { (alert) in
					let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: { (action) in
						alert.dismissViewControllerAnimated(true, completion: nil)
					})
					
					let start  = UIAlertAction(title: "起始点", style: .Default, handler: { (action) in
						//设为起始点
						self._searchPlaceClass!.setStartPoint(annotationView: view!)
					})
					
					let end    = UIAlertAction(title: "终点", style: .Default, handler: { (action) in
						//设为终点
						self._searchPlaceClass!.setEndPoint(annotationView: view!)
					})
					
					alert.addAction(cancel)
					alert.addAction(start)
					alert.addAction(end)
				})
			}
			
			view!.addGestureRecognizer(press)
			
			
			return view
		}
	}
	
	
	/**
	*根据overlay生成对应的View
	*@param mapView 地图View
	*@param overlay 指定的overlay
	*@return 生成的覆盖物View
	*/
	func mapView(mapView: BMKMapView!, viewForOverlay overlay: BMKOverlay!) -> BMKOverlayView! {
		if overlay as! BMKPolyline? != nil {
			let polylineView = BMKPolylineView(overlay: overlay as! BMKPolyline)
			polylineView.strokeColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.7)
			polylineView.lineWidth = 3
			return polylineView
		}
		return nil
	}
	
	
	//MARK: - 选择城市点击事件
	func chooseCityTapped(sender: UIButton) {
		if _isChoosingCity == false {
			if _chooseCityClass == nil {
				_chooseCityClass = ChooseCity(target: self)
			}
			else {
				_chooseCityClass!.showTableView()
			}

            _isChoosingCity  = true
		}
		else {
			_chooseCityClass!.removeFromSuperView()
			
			_isChoosingCity = false
		}
	}
	
	
	//MARK: - 清除大头针
	@IBAction func clearAnnotations(sender: UIButton) {
		_mapView.removeAnnotations(_mapView.annotations)
		
		//去掉路径规划启动按钮
		if _searchPlaceClass != nil {
			_searchPlaceClass!.ifRemoveStartRouteSearchButton()
		}
	}
	
	
	//MARK: - 禁启用所有功能
	func disableAllCapabilities(without capas: Capabilities...) {
		var shouldEnable = [Bool](count: 4, repeatedValue: true)
		
		
		for capa in capas {
			if capa == .ClearAnnos {
				shouldEnable[0] = false
			}
			if capa == .FindRoute {
				shouldEnable[1] = false
			}
			if capa == .FollowMode {
				shouldEnable[2] = false
			}
			if capa == .SearchField {
				shouldEnable[3] = false
			}
		}
		
		
		if shouldEnable[0] {
			_clearAnotationsButton.userInteractionEnabled = false
			_clearAnotationsButton.alpha = 0
		}
		if shouldEnable[1] {
			_searchPlaceClass?._routeSearchStartButton?.userInteractionEnabled = false
			_searchPlaceClass?._routeSearchStartButton?.alpha = 0
		}
		if shouldEnable[2] {
			_isFollowButton.userInteractionEnabled = false
			_isFollowButton.alpha = 0
		}
		if shouldEnable[3] {
			_searchTextField.userInteractionEnabled = false
			_searchTextField.alpha = 0
		}
	}
	
	func enableAllCapabilities(without capas: Capabilities...) {
		var shouldDisable = [Bool](count: 4, repeatedValue: true)
		
		
		for capa in capas {
			if capa == .ClearAnnos {
				shouldDisable[0] = false
			}
			if capa == .FindRoute {
				shouldDisable[1] = false
			}
			if capa == .FollowMode {
				shouldDisable[2] = false
			}
			if capa == .SearchField {
				shouldDisable[3] = false
			}
		}
		
		
		if shouldDisable[0] {
			_clearAnotationsButton.userInteractionEnabled = true
			_clearAnotationsButton.alpha = 1
		}
		if shouldDisable[1] {
			_searchPlaceClass?._routeSearchStartButton?.userInteractionEnabled = true
			_searchPlaceClass?._routeSearchStartButton?.alpha = 1
		}
		if shouldDisable[2] {
			_isFollowButton.userInteractionEnabled = true
			_isFollowButton.alpha = 1
		}
		if shouldDisable[3] {
			_searchTextField.userInteractionEnabled = true
			_searchTextField.alpha = 1
		}
	}
}