//
//  CarViewController.swift
//  CarManagement
//
//  Created by zhy on 16/5/14.
//  Copyright © 2016年 随便. All rights reserved.
//

import UIKit
import SwiftyJSON


class CarViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var _scrollView: UIScrollView!
	@IBOutlet weak var _tableView: UITableView!
	@IBOutlet weak var _pageCtrl: UIPageControl!
	@IBOutlet weak var _mainView: UIView!
	@IBOutlet weak var _sideTableView: UITableView!//汽车列表
	
	@IBOutlet weak var _listButton: UIButton!
	@IBOutlet weak var _inquiryRulesBreakButton: UIButton!
	@IBOutlet weak var _addNewCarButton: UIButton!
	
	@IBOutlet weak var _pageCtrlTop: NSLayoutConstraint!
	
	var _dataSource: [[String]]?
	
    var _carImages  = [UIImageView]()//车身图片
    var _logoImages = [UIImageView]()//logo图片
	
	
	var _numOfImages: Int! {
		//images数量改变时触发
		willSet {
			if newValue <= 0 {
				ifNoCars()
			}
			else {
				//scrollView容量变化
				_scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * CGFloat(newValue), _scrollView.frame.height)
				
				//pageCtrl数量变化
				_pageCtrl.numberOfPages = newValue
				
				//重新添加images
				addImages(newValue)
				
				//启用
				ifHasCars()
			}
		}
	}
	
	var _noCarsLabel: UILabel?
	
	var _isSideViewShown = false {//边栏是否显示
		willSet {
			if newValue == true {
				showSideTableView()
			}
			else {
				hideSideTableView()
			}
		}
	}
	
	
	//MARK: - 预加载
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
        let label       = UILabel()
        label.text      = "我的爱车"
        label.textColor = UIColor.whiteColor()
        label.font      = UIFont.boldSystemFontOfSize(18)
		label.sizeToFit()
		
		self.navigationItem.titleView = label
		
		//mainView阴影
        _mainView.layer.shadowOffset  = CGSizeMake(6, 0)
        _mainView.layer.shadowColor   = UIColor.lightGrayColor().CGColor
        _mainView.layer.shadowOpacity = 0.8
		
		//轮播图片数量
		_numOfImages = (UserInfo.carInfo == nil) ? 0 : UserInfo.carInfo!.count
		
		//分页指示器设置
		_pageCtrl.currentPage = 0
		
		//刷新头
		_tableView.mj_header = MJRefreshNormalHeader.refreshingAction({ 
			//获取数据
			self.updateDataSource(self._pageCtrl.currentPage) {
				//刷新数据
				self._numOfImages = UserInfo.carInfo!.count
				self._tableView.reloadData()
				
				self._tableView.mj_header.endRefreshing()
			}
		})
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		//刷新数据
		_tableView.mj_header.beginRefreshing()
	}
	
	override func viewDidLayoutSubviews() {
		//分页指示器设置
		_pageCtrlTop.constant = _scrollView.frame.height - _pageCtrl.frame.height
	}
	
	func addImages(num: Int) {
		if !_carImages.isEmpty {
			for i in 0..<num {
				_carImages[i].removeFromSuperview()
				_logoImages[i].removeFromSuperview()
			}
			
			_carImages.removeAll()
			_logoImages.removeAll()
		}
		
		//添加轮播图片
		for i in 0..<num {
			//车身图片
			let imageView = UIImageView(frame: CGRectMake(SCREEN_WIDTH * CGFloat(i), 0, SCREEN_WIDTH, _scrollView.frame.height))
			
			SetImageView(imageView, imageURL: UserInfo.carInfo?[i].image, circle: false)
			
			_scrollView.addSubview(imageView)
			_carImages.append(imageView)
			
			//logo图片
			let imageView2 = UIImageView(frame: CGRectMake(SCREEN_WIDTH * CGFloat(i + 1) - 60, 0, 60, 60))
			
			SetImageView(imageView2, imageURL: UserInfo.carInfo![i].logo, circle: false)
			
			_scrollView.addSubview(imageView2)
			_logoImages.append(imageView2)
		}
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
	
	//MARK: - scrollview代理
	func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
		if scrollView.isEqual(_scrollView) {
			//分页控制器换页
			_pageCtrl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
			
			//换页事件
			updateDataSource(_pageCtrl.currentPage) {
				self._tableView.reloadData()
			}
		}
	}
	
	//MARK: - tableview代理
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (_dataSource == nil) ? 0 : _dataSource!.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let indentifier = "carinfo"
		var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(indentifier)
		
		if cell == nil {
			cell = UITableViewCell(style: .Value1, reuseIdentifier: indentifier)
		}
		
		cell!.textLabel?.text       = _dataSource![indexPath.row][0]
		cell!.detailTextLabel?.text = _dataSource![indexPath.row][1]
		
		cell!.selectionStyle        = .None
		
		return cell!
	}
	
	//MARK: - 更新tableview数据源
	func updateDataSource(page: Int, callBack action: () -> Void) {
		if UserInfo.carInfo != nil {
			//请求到新数据之前使用旧数据
			parseCarInfo(page)
			action()
		}
		
		//更新数据
		UserInfo.update(withType: .Car, completionHandler: {
			//执行解析与回调
			self.parseCarInfo(page)
			action()
		})
	}
	
	func parseCarInfo(page: Int) {
		let carInfo = UserInfo.carInfo![page]
		
		_dataSource = [
			["车型", carInfo.model],
			["车牌号", carInfo.carNum],
			["发动机号", carInfo.engineNum],
			["车身级别", "\(carInfo.bodyLevel[0])门\(carInfo.bodyLevel[1])座"],
			["里程", String(carInfo.distance)],
			["汽油量", String(carInfo.restGas)],
			["发动机状态", (carInfo.engineStatus == 1) ? "好" : "需要维护"],
			["变速器状态", (carInfo.transmissionStatus == 1) ? "好" : "需要维护"],
			["车灯状态", (carInfo.light == 1) ? "好" : "需要维护"]
		]
		
		//若有特殊辨识名称，则添加
		if carInfo.name != nil {
			_dataSource!.insert(["自定义名称", carInfo.name!], atIndex: _dataSource!.startIndex)
		}
	}
	
	
	//MARK: - 右上角按钮：违章查询与汽车列表
	//查询违章
	@IBAction func searchRecordOfBearkingRules(sender: AnyObject) {
        
	}
	
	//显示汽车列表
	var _sideDelegator: CarSideTableViewDelegator?//边栏tableView代理
	
	@IBAction func changeSideStatus(sender: AnyObject) {
		_isSideViewShown = !_isSideViewShown
	}
	
	func showSideTableView() {
		//数据源
		var sideDataSource = [String]()
		
		for car in UserInfo.carInfo! {
			sideDataSource.append("\(car.branch) \(car.model)" + ((car.name == nil) ? "" : "(\(car.name))"))
		}
		
		//设置代理
		_sideDelegator = CarSideTableViewDelegator(target: self, delegateForTableView: _sideTableView, dataSource: sideDataSource)
        _sideTableView.delegate   = _sideDelegator
        _sideTableView.dataSource = _sideDelegator
		
		_sideTableView.reloadData()
		
		//动画显示
		UIView.animateWithDuration(0.3) {
			self._mainView.frame = CGRectMake(-SCREEN_WIDTH / 3 * 2, 0, SCREEN_WIDTH, self.view.frame.height)
		}
	}
	
	func hideSideTableView() {
		//动画隐藏
		UIView.animateWithDuration(0.3) {
			self._mainView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.height)
		}
		
		//释放代理
		_sideDelegator = nil
	}
	
	
	//MARK: - 如果没有车辆
	func ifNoCars() {
        _listButton.hidden              = true
        _inquiryRulesBreakButton.hidden = true

        _mainView.hidden                = true
        _sideTableView.hidden           = true
		
		//告知无车
		_noCarsLabel = UILabel()
		
        _noCarsLabel!.text  = "暂无车辆"
        _noCarsLabel!.font  = UIFont.boldSystemFontOfSize(40)
		_noCarsLabel!.sizeToFit()

        _noCarsLabel!.frame = CGRectMake(
			(SCREEN_WIDTH - _noCarsLabel!.frame.width) / 2,
			(self.view.frame.height - _noCarsLabel!.frame.height) / 2,
			_noCarsLabel!.frame.width,
			_noCarsLabel!.frame.height)
	}
	
	func ifHasCars() {
		_listButton.hidden              = false
		_inquiryRulesBreakButton.hidden = false
		
		_mainView.hidden                = false
		_sideTableView.hidden           = false
		
		_noCarsLabel?.removeFromSuperview()
		_noCarsLabel = nil
	}
}
