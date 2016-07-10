//
//  ShowBreakRulesViewController.swift
//  CarManagement
//
//  Created by zhy on 16/5/19.
//  Copyright © 2016年 随便. All rights reserved.
//

import UIKit


class ShowBreakRulesViewController: UIViewController {

	@IBOutlet weak var _tableView: UITableView!
	
	var _carId: Int!
	
	var _dataSource: [String]?
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		_ = UserInfo.carInfo![_carId]
		
		
//		PostWithInterface(service: "http://www.cheshouye.com/api/weizhang/query_task",
//		                   parameters: ["car_info": ["hphm" : car.carNum,
//												  "classno" : car.classNum,
//												 "engineno" : car.engineNum,
//												  "city_id" : car.cityId,
//												 "car_type" : car]])
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
