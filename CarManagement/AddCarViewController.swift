//
//  AddCarViewController.swift
//  CarManagement
//
//  Created by zhy on 16/5/19.
//  Copyright © 2016年 随便. All rights reserved.
//

import UIKit
import SwiftyJSON


class AddCarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	
	@IBOutlet weak var _tableView: UITableView!
    
    var _json: JSON!//由二维码传递的数据
	
	var _textField: UITextField!
	
	var _dataSource: [String]!
	
	var _result = [String]()//cell右侧内容
	
	var _imagePicker: UIImagePickerController?
	var _pickedImage: UIImage?
	var _imageView: UIImageView?
	
	
	
	//MARK: - 预加载
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		//title
		let label = UILabel()
		
		label.text      = "添加新车"
		label.textColor = UIColor.whiteColor()
		label.sizeToFit()
		
		self.navigationItem.titleView = label
		
		
		//点击空白退出键盘
		let tap = CMTapGestureRecognizer.addTarget {
			if self._textField.isFirstResponder() {
				let cell = self._tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: self._textField.tag))!
				
				//还原文本
				cell.detailTextLabel?.text = self._textField.text
				
				//删除文本框
				self._textField.removeFromSuperview()
			}
			
			//键盘退出活跃状态
			self._textField.resignFirstResponder()
		}
		
		tap.cancelsTouchesInView = false//tap可穿透view上的subviews
		
		self.view.addGestureRecognizer(tap)
		
		//文本框初始化
		let textX: CGFloat = 16 + 16 * 10
		
		_textField = UITextField(frame: CGRectMake(textX, 8, SCREEN_WIDTH - textX - 16, 44 - 8 - 8))
		
		//数据源
		_dataSource = [
			"自定义名称（可选）",
			"图片（单击上传）",
			"我们将识别您的车辆，并将其他具体信息上载至服务器，具体包括：\n品牌，logo，车辆型号，车身级别（几门几座），车牌号。剩余油量，里程，发动机号，以及其他一些部件的运行状态"
		]
        
        _ = UploadData(data: NSKeyedArchiver.archivedDataWithRootObject(UIImage(named: "")!), name: "user_image", fileName: "1.png", mimeType: "image/png")
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
	
	
	//MARK: - tableView代理和数据源
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return _dataSource.count - 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 1
	}
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 9
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		if indexPath.section == 1 {
			return 60
		}
		
		return 44
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let identifier = "carinfo"
		var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(identifier)
		
		if cell == nil {
			cell = UITableViewCell(style: .Value1, reuseIdentifier: identifier)
		}
		
		cell!.textLabel?.text       = _dataSource[indexPath.section]
		cell!.detailTextLabel?.text = (_result.count - 1 > indexPath.section) ? _result[indexPath.section] : nil//如果对应行有结果就赋值
		cell!.textLabel?.font       = UIFont.systemFontOfSize(16)
		cell!.detailTextLabel?.font = UIFont.systemFontOfSize(16)
		
		return cell!
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		switch indexPath.section {
		case 0:
			let cell = tableView.cellForRowAtIndexPath(indexPath)!
			
			cell.detailTextLabel?.text = ""
			cell.contentView.addSubview(_textField)
			
			_textField.tag = indexPath.section
			_textField.becomeFirstResponder()
			
			
		//选取车身图片
		case 1:
			ShowActionSheet(target: self, andActions: { (ctrl) in
				let cancel = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
				let takePhoto = UIAlertAction(title: "拍照", style: .Default, handler: { (action) in
					if self._imagePicker == nil {
						self._imagePicker = UIImagePickerController()
						
						self._imagePicker!.delegate      = self
						self._imagePicker!.allowsEditing = true
					}
					
					self._imagePicker!.sourceType = .Camera
					
					self.presentViewController(self._imagePicker!, animated: true, completion: {
						UIApplication.sharedApplication().statusBarStyle = .Default
					})
				})
				let choosePhoto = UIAlertAction(title: "从相册中选择...", style: .Default, handler: { (action) in
					if self._imagePicker == nil {
						self._imagePicker = UIImagePickerController()
						
						self._imagePicker!.delegate      = self
						self._imagePicker!.allowsEditing = true
					}
					
					self._imagePicker!.sourceType = .PhotoLibrary
					
					self.presentViewController(self._imagePicker!, animated: true, completion: {
						UIApplication.sharedApplication().statusBarStyle = .Default
					})
				})
				
				ctrl.addAction(cancel)
				ctrl.addAction(takePhoto)
				ctrl.addAction(choosePhoto)
			})
			
		default:
			break
		}
		
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
	
	//MARK: - 图片选取器
	func imagePickerControllerDidCancel(picker: UIImagePickerController) {
		UIApplication.sharedApplication().statusBarStyle = .LightContent
		picker.dismissViewControllerAnimated(true, completion: nil)
	}
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
		_pickedImage = image
		
		//添加缩略图
		if _imageView == nil {
			let imageSize: CGFloat = 60 - 8 - 8
			
			_imageView = UIImageView(frame: CGRectMake(SCREEN_WIDTH - 16 - imageSize, 8, imageSize, imageSize))
			_tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 1))!.contentView.addSubview(_imageView!)
		}
		
		//设置缩略图
		SetImageView(_imageView!, image: image, circle: true)
		
		//结束图片选取
		picker.dismissViewControllerAnimated(true, completion: {
			UIApplication.sharedApplication().statusBarStyle = .LightContent
		})
	}
}
