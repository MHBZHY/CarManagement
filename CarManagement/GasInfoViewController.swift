//
//  GasInfoViewController.swift
//  CarManagement
//
//  Created by zhy on 16/5/12.
//  Copyright © 2016年 随便. All rights reserved.
//

import UIKit
import SwiftyJSON


class GasInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var _tableView: UITableView!
	
	var _json: JSON!//显示用数据
	var _tableData: [[[String]]]!//tableView数据源
	
	var _nameLable: UILabel!//名称
	var _addressLabel: UILabel!//地址
	
	let infoCellHeight: CGFloat = 50
	let priceCellHeight: CGFloat = 40
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        // Do any additional setup after loading the view.
		//设置title
		self.title = "加油站详情"
		
		//拼接tableData数据源
		_tableData = [
			//加油站基本信息
			[
				["运营商类型", _json["brandname"].stringValue],
				["折扣信息", _json["discount"].stringValue],
				["加油站类型", _json["type"].stringValue],
				["尾气排放标准", _json["exhaust"].stringValue],
				["加油卡信息", _json["fwlsmc"].stringValue],
				["距离", _json["distance"].stringValue + "m"]
			]
			//参考价格信息，拼接得来
		]
		
		//拼接参考价格信息
		var priceInfo = [[String]]()
		
//		for price in _json["gastprice"].arrayValue {
//			priceInfo.append([price["name"].stringValue, price["price"].stringValue])
//		}
		
		for price in _json["gastprice"].dictionaryValue {
			priceInfo.append([price.0, "¥\(price.1.stringValue)/L"])
		}
		
		//将价格信息加入tableData
		_tableData.append(priceInfo)
		
		
		//下移tableView
		_tableView.contentInset = UIEdgeInsetsMake(100, 0, 0, 0)
		
		//初始化nameLabel, addressLabel
		_nameLable = UILabel(frame: CGRectMake(8, -100, SCREEN_WIDTH - 8 - 8, 40))
		
		_nameLable.text = _json["name"].stringValue
		_nameLable.font = UIFont.boldSystemFontOfSize(18)
		
		
		_addressLabel = UILabel(frame: CGRectMake(_nameLable.frame.minX, _nameLable.frame.maxY, SCREEN_WIDTH - 8 - 8, 40))
		
        _addressLabel.text          = _json["address"].stringValue
        _addressLabel.font          = UIFont.italicSystemFontOfSize(14)
        _addressLabel.numberOfLines = 2
        _addressLabel.textColor     = UIColor.grayColor()
		
		
		//添加两个label
		_tableView.addSubview(_nameLable)
		_tableView.addSubview(_addressLabel)
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
	
	
	//MARK: - tableView代理方法
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return _tableData[section].count
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 1
	}
	
	func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		if section == 0 {
			return 19
		}
		else {
			return 1
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.section == 0 {
			//加油卡信息
			if indexPath.row == 4 {
				return infoCellHeight + 14
			}
			
			return infoCellHeight
		}
		else {
			return priceCellHeight
		}
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let identifier = "info"
			var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(identifier)
			
			if cell == nil {
				cell = UITableViewCell(style: .Value1, reuseIdentifier: identifier)
			}
			
            cell!.textLabel?.text       = _tableData[indexPath.section][indexPath.row][0]
            cell!.detailTextLabel?.text = _tableData[indexPath.section][indexPath.row][1]
			cell!.detailTextLabel?.adjustsFontSizeToFitWidth = true
			cell!.detailTextLabel?.numberOfLines = 3
            cell!.selectionStyle        = .None
			
			return cell!
		}
		else {
			let identifier = "price"
			var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(identifier)
			
			if cell == nil {
				cell = UITableViewCell(style: .Value1, reuseIdentifier: identifier)
			}
			
            cell!.textLabel?.text       = _tableData[indexPath.section][indexPath.row][0]
            cell!.detailTextLabel?.text = _tableData[indexPath.section][indexPath.row][1]
            cell!.selectionStyle        = .None
			
			//添加竖线
			let layer = CALayer()
			
			layer.frame = CGRectMake(SCREEN_WIDTH / 2 - 1, 0, 1, priceCellHeight)
			layer.backgroundColor = UIColor ( red: 0.9373, green: 0.9373, blue: 0.9569, alpha: 1.0 ).CGColor
			
			cell!.contentView.layer.addSublayer(layer)
			
			return cell!
		}
	}
	
	
	//MARK: - 预约加油
	var _alertController: UIAlertController? //预约加油时弹出的alert
	var _alertTextField: UITextField?
	var _price: Double?	//油价
	var _textFieldDelegate = TextFieldDelegate()
	
	
	@IBAction func reserveGas(sender: UIButton) {
		//生成价格表
		var priceInfo = [String : Double]()
		
		for data in _tableData[1] {
			var price = data[1]
			price.removeAtIndex(price.startIndex)
			price.removeRange(price.endIndex.advancedBy(-2)..<price.endIndex)
			priceInfo[data[0]] = Double(price)
		}
		
		
		ShowAlertController(forTarget: self, withStyle: .Alert, alertTitle: "预约加油", message: "选择油类") { (ctrl) -> [UIAlertAction] in
			var actions = [UIAlertAction]()
			
			//遍历价格信息生成按钮
			for price in priceInfo {
				let action = UIAlertAction(title: price.0, style: .Default, handler: { (action) in
                    
					//弹出第二个对话框
					self._alertController = ShowAlertController(forTarget: self, withStyle: .Alert, alertTitle: "输入油量", message: "价格：¥0.00") { (ctrl) -> [UIAlertAction] in
						let confirm = UIAlertAction(title: "确认并选择日期", style: .Destructive, handler: { (action) in
							//确认油量
//							self.sendReserveMessage(gasType: price.0, amount: Int(self._alertTextField!.text!)!, price: Double(self._alertTextField!.text!)! * price.1)
                            let amount = Int(self._alertTextField!.text!)!
							let priceNum = Double(self._alertTextField!.text!)! * price.1
                            
                            //弹出日期选择器
                            _ = ShowDatePicker(target: self, mode: .Date, frame: nil, completionHandler: { (date) in
                                self.sendReserveMessage(gasType: price.0, amount: amount, price: priceNum, date: date)
                            })
						})
                        
						let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
						
						//添加 '输入预约油量' 文本框
						ctrl.addTextFieldWithConfigurationHandler { (textField) in
							textField.placeholder = "请输入预约油量(L)"
							
							//添加监视
							textField.addTarget(self, action: #selector(self.reserveGasTextChanged(_:)), forControlEvents: .EditingChanged)
							
							//添加代理，控制输入
							textField.delegate = self._textFieldDelegate
							
							//油价赋值
							self._price = price.1
							
							self._alertTextField = textField
						}
						
						//返回actions
						return [confirm, cancel]
					}
				})
				
				actions.append(action)
			}
			
			return actions
		}
	}
	
	//alertwindow文本框监听
	func reserveGasTextChanged(textField: UITextField) {
		let account = (textField.text == "") ? 0.00 : Double(textField.text!)!
		
		_alertController!.message = "价格：¥" + String(format: "%.2f", account * _price!)
//		print(textField.delegate)
	}
	
	//预约加油
    func sendReserveMessage(gasType type: String, amount: Int, price: Double, date: NSDate) {
        let tempAlert = ShowAlertController(forTarget: self, withStyle: .Alert, alertTitle: nil, message: "预约中...", addActions: nil)
        
        //配置网络连接
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = 12
        
        PostWithInterface("ReserveGas", parameters: ["type": type, "amount": amount, "price": price], andConfiguration: configuration)
            .responseJSON { (res) in
                if res.result.isSuccess {
                    if res.result.value != nil {
                        //终止临时alert
                        tempAlert.dismissViewControllerAnimated(true, completion: {
                            //临时alert终止后
                            print("预约完成")
                            //                            self.performSegueWithIdentifier("", sender: nil)
                        })
                    }
                } else {
                    tempAlert.dismissViewControllerAnimated(true, completion: { 
                        ShowAlertController(forTarget: self, withStyle: .Alert, alertTitle: "连接出错", message: "请检查您的网络连接", addActions: { (ctrl) -> [UIAlertAction] in
                            let ok = UIAlertAction(title: "好", style: .Default, handler: nil)
                            return [ok]
                        })
                    })
                }
        }
	}
}
