//
//  OrderInfoTableViewController.swift
//  CarManagement
//
//  Created by zhy on 16/5/22.
//  Copyright © 2016年 随便. All rights reserved.
//

import UIKit
import SwiftyJSON


class OrderInfoTableViewController: UITableViewController {
    
    var _id: Int!
    var _dataSource: [[[String]]]?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        SetNavItemTitle("订单详情", color: UIColor.whiteColor(), forItem: navigationItem)
        
        
        if UserInfo.orderInfo != nil {
            let order = UserInfo.orderInfo![_id]
            
            _dataSource = [
                [
                    ["下单时间", order.time],
                    ["预约时间", order.reserveTime],
                    ["油量", String(order.volume)],
                    ["类型", order.type],
                    ["价格", String(order.price)],
                    ["加油站", order.station],
                    ["二维码", ""]
                ]
            ]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (_dataSource == nil) ? 0 : _dataSource![section].count
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "reuseIdentifier"
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(identifier)

        // Configure the cell...
        if cell == nil {
            cell = UITableViewCell(style: .Value1, reuseIdentifier: identifier)
        }
        
        cell!.textLabel?.text       = _dataSource![indexPath.section][indexPath.row][0]
        cell!.detailTextLabel?.text = _dataSource![indexPath.section][indexPath.row][1]
        cell!.selectionStyle        = .None
        
        if indexPath.row == _dataSource![indexPath.section].count - 1 {
            cell!.selectionStyle = .Default
            cell!.accessoryType  = .DisclosureIndicator
        }

        return cell!
    }
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
}
