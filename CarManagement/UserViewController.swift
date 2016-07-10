//
//  UserViewController.swift
//  CarManagement
//
//  Created by zhy on 16/4/11.
//  Copyright © 2016年 随便. All rights reserved.
//

import UIKit
import SwiftyJSON


class UserViewController: UIViewController {

	@IBOutlet weak var _tableView: UITableView!
	
	//tableView数据源
    var _tableRows: [[[String : String]]]?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        _tableRows = [
            [
                ["name" : "Welcome", "face" : (UserInfo.face == nil) ? "" : UserInfo.face!],
                ["text" : "我的订单", "image" : "User"],
                ["text" : "我的爱车", "image" : "User"]
            ],
            [
                ["text" : "查看我的详细信息"],
                ["text" : "修改我的密码"],
                ["text" : "选择音乐"]
            ]
        ]
		
		
		//MARK: - 刷新时动作
		_tableView.mj_header = MJRefreshNormalHeader.refreshingAction({
            UserInfo.update(phoneNum: nil, completionHandler: {
				//更新姓名和头像
				self._tableRows![0][0]["name"] = UserInfo.name
				self._tableRows![0][0]["face"] = UserInfo.face
				
				//刷新tableview
				self._tableView.reloadData()
				
				//停止header
				self._tableView.mj_header.endRefreshing()
			})
		})
		
		
		//如果userinfo为空, 开始刷新
		if UserInfo == nil {
			_tableView.mj_header.beginRefreshing()
		}
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		UIApplication.sharedApplication().statusBarStyle = .LightContent
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

}


//MARK: - tableview方法
extension UserViewController: UITableViewDataSource, UITableViewDelegate, TypeButtons {
	//MARK: - cell 数量
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (_tableRows == nil) ? 0 : _tableRows!.count
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		switch section {
//		case 0:
//			return 2
//		default:
//			return _tableRows.count
//		}
		
		return (section == 0) ? 2 : _tableRows![section].count
	}
	
	//MARK: - cell 高度
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//		if indexPath.section == 0 {
//			//用户
//			if indexPath.row == 0 {
//				return 100
//			}
//			//功能键
//			else {
//				return 50
//			}
//		}
//		//其余行
//		else {
//			return 44
//		}
		
		return (indexPath.section == 0) ? ((indexPath.row == 0) ? 100 : 50) : 44
	}
	
	
	func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 1
	}
	
	func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 19
	}
	
	
	//MARK: - cell 内容
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let content = _tableRows![indexPath.section][indexPath.row]
		
		switch indexPath.section {
		case 0:
			switch indexPath.row {
			case 0:
				let cell = tableView.dequeueReusableCellWithIdentifier("user") as! UserTableViewCell
				
				SetImageView(cell.faceImageView, imageURL: content["face"]!, circle: true)
				cell.nameLabel.text = content["name"]!
                
                cell.selectionStyle = .None
				
				return cell
				
			default:
				let cell = tableView.dequeueReusableCellWithIdentifier("type") as! UserTypeTableViewCell
				
				let items = _tableRows![indexPath.section]
				
				//按钮个数
				for i in 1...2 {
					//按钮文本
					cell.texts.append(items[i]["text"]!)
					//按钮图像
					cell.images.append(items[i]["image"]!)
					
					//button action
					cell.buttons[i - 1].addTarget(self, action: #selector(typeButtonsDidTapped(_:)), forControlEvents: .TouchUpInside)
				}
				
				
				//设置cell中的按钮
				cell.setViewsWithSize(CGSizeMake(self.view.frame.width, 50))
                
                cell.selectionStyle = .None
				
				return cell
			}
			
		default:
			let identifier = "default"
			var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(identifier)
			
			if cell == nil {
				cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
			}
			
//			cell!.imageView!.image = UIImage(named: content["image"]!)
			cell!.textLabel!.text = content["text"]!
			
			return cell!
		}
	}
	
    
    //MARK: - table选择事件
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                self.performSegueWithIdentifier("Show&ChangeUserInfo", sender: 1)
                
            case 1:
                self.performSegueWithIdentifier("ChangePassword", sender: 1)
                
            case 2:
//                self.performSegueWithIdentifier(<#T##identifier: String##String#>, sender: <#T##AnyObject?#>)
                break
                
            default:
                break
            }
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
	
	//MARK: - cell内 按钮 响应事件
	func typeButtonsDidTapped(btn: UIButton) {
		switch btn.tag {
		//我的订单
		case 0:
			self.performSegueWithIdentifier("ShowOrderList", sender: nil)
			break
		//我的爱车
		case 1:
			self.performSegueWithIdentifier("ShowCars", sender: nil)
			
		default:
			break
		}
	}
}