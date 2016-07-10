//
//  ShowGasStation.swift
//  CarManagement
//
//  Created by zhy on 16/5/11.
//  Copyright © 2016年 随便. All rights reserved.
//

import Alamofire
import SwiftyJSON


class ShowGasStation {
	var _gasInfo: [JSON]?
	var _gasAnnotations: [BMKAnnotation]?
	
	
	//MARK: - 获取周边加油站
	func getNearGasStation(withUserLocation coordinate: CLLocationCoordinate2D, callBack action: [BMKAnnotation] -> Void) {
		request(.GET, "http://apis.juhe.cn/oil/local",
		        parameters: ["lat": coordinate.latitude,
							 "lon": coordinate.longitude,
							 "key": GAS_AK],
		        encoding: .URL, headers: nil)
            .responseJSON { (res) in
                if res.result.isSuccess {
                    if res.result.value != nil {
                        let json = JSON(res.result.value!)
                        //					print(json)
                        //生成大头针
                        //清理数组
                        self._gasAnnotations = [BMKPointAnnotation]()
                        
                        //添加加油站大头针
                        self._gasInfo = json["result"]["data"].arrayValue
                        
                        for data in self._gasInfo! {
                            let annotation = BMKPointAnnotation()
                            
                            annotation.title = data["name"].stringValue
                            annotation.coordinate = CLLocationCoordinate2DMake(data["lat"].doubleValue, data["lon"].doubleValue)
                            annotation.subtitle = "加油站"
                            
                            self._gasAnnotations!.append(annotation)
                        }
                        
                        
                        //执行回
                        action(self._gasAnnotations!)
                    }
                }
		}
	}
}