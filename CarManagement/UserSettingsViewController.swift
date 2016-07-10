//
//  UserSettingsViewController.swift
//  CarManagement
//
//  Created by zhy on 16/5/23.
//  Copyright © 2016年 随便. All rights reserved.
//

import UIKit

class UserSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var _tableView: UITableView!
    
    var _dataSource = [
        ["清除缓存"],
        ["关于我们"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let titleLabel       = UILabel()
        titleLabel.text      = "设定"
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font      = UIFont.boldSystemFontOfSize(18)
        titleLabel.sizeToFit()
        
        self.navigationItem.titleView = titleLabel
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
        return _dataSource.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 14
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "setting"
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(identifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: identifier)
        }
        
        cell!.textLabel?.text = _dataSource[indexPath.section][indexPath.row]
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            //清理缓存
            break
            
        case 1:
            //关于我们
            break
            
        default:
            break
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
