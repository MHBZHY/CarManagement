//
//  OrderListViewController.swift
//  CarManagement
//
//  Created by zhy on 16/5/22.
//  Copyright © 2016年 随便. All rights reserved.
//

import UIKit
import SwiftyJSON


class OrderListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var _tableView: UITableView!
    
    var _json: JSON?
    var _dataSource: [[[String : String]]]?
    
    let _cellHeight: CGFloat = 80
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let titleLabel       = UILabel()
        titleLabel.text      = "我的订单"
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font      = UIFont.boldSystemFontOfSize(18)
        titleLabel.sizeToFit()
        
        self.navigationItem.titleView = titleLabel
        
        
        //刷新头设置
        _tableView.mj_header = MJRefreshNormalHeader.refreshingAction({
            UserInfo.update(withType: .Order, completionHandler: { 
                self.geneDataSource()
                
                self._tableView.reloadData()
                self._tableView.mj_header.endRefreshing()
            })
        })
        
        _tableView.mj_header.beginRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func geneDataSource() {
        _dataSource = [[[String : String]]]()
        _dataSource!.append([[String : String]]())
        
        for order in UserInfo.orderInfo! {
            _dataSource![0].append(["time": order.reserveTime,
                                   "price": String(order.price),
                                 "address": order.station])
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowOrderInfo" {
            let destVC = segue.destinationViewController as! OrderInfoTableViewController
            
            //将所需json传递过去
            destVC._id = sender as! Int
        }
    }

    
    //MARK: - tableView数据源及代理
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (_dataSource == nil) ? 0 : _dataSource![section].count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return _cellHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return OrderListTableViewCell.initWithSize(CGSizeMake(SCREEN_WIDTH, _cellHeight), tableView: tableView, reuseIdentifier: "order") { (orderCell) in
            let data = self._dataSource![indexPath.section][indexPath.row]
        
            orderCell.timeLabel.text = data["time"]
            orderCell.addressLabel.text = data["address"]
            orderCell.priceLabel.text = data["price"]
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ShowOrderInfo", sender: indexPath.row)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
