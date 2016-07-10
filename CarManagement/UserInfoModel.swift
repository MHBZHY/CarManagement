//
//  UserInfoModel.swift
//  CarManagement
//
//  Created by zhy on 16/5/2.
//  Copyright © 2016年 随便. All rights reserved.
//

import SwiftyJSON


public class UserInfoModel: NSObject {
	
	enum UpdateType {
		case Car
		case Order
	}
	
	//MARK: - 成员变量
	var name: String!	//用户姓名
	var face: String?	//用户头像url
	var phone: String!	//电话号码
	var carInfo: [CarInfo]?		//汽车信息
	var orderInfo: [OrderInfo]?		//订单信息
    
    var isLogin: Bool!//是否登录
	
	
	//MARK: - 汽车信息
	class CarInfo: NSObject, NSCoding {
		var name: String?		//可选昵称
		var branch: String!		//品牌
		var logo: String!		//标志
		var model: String!		//汽车型号
		var image: String!		//汽车图片
		var carNum: String!		//车牌号
		var engineNum: String!	//发动机号
		var classNum: String!	//车架号
		var distance: Double!	//里程
		var restGas: Double!		//剩余油量（％）
		var bodyLevel: [Int]!	//车身级别，几门几座
		var engineStatus: Int!	//引擎状态
		var transmissionStatus: Int!//变速器状态
		var light: Int!			//车灯状态
		var cityId: Int!			//所在城市编号
		var carType: String!		//汽车类型
		
		
		init(name: String?, branch: String!, logo: String!, model: String!, image: String!, carNum: String!, engineNum: String!, classNum: String!, distance: Double!, restGas: Double!, bodyLevel: [Int]!, engineStatus: Int!, transmissionStatus: Int!, light: Int!, cityId: Int!, carType: String!) {
            self.name               = name
            self.branch             = branch
            self.logo               = logo
            self.model              = model
            self.image              = image
            self.carNum             = carNum
            self.engineNum          = engineNum
            self.classNum           = classNum
            self.distance           = distance
            self.restGas            = restGas
            self.bodyLevel          = bodyLevel
            self.engineStatus       = engineStatus
            self.transmissionStatus = transmissionStatus
            self.light              = light
            self.cityId             = cityId
            self.carType            = carType
		}
        
		func encodeWithCoder(aCoder: NSCoder) {
			aCoder.encodeObject(name, forKey: "name")
            aCoder.encodeObject(branch, forKey: "branch")
			aCoder.encodeObject(logo, forKey: "logo")
            aCoder.encodeObject(model, forKey: "model")
            aCoder.encodeObject(image, forKey: "image")
            aCoder.encodeObject(carNum, forKey: "carnum")
            aCoder.encodeObject(engineNum, forKey: "engineNum")
            aCoder.encodeObject(classNum, forKey: "classNum")
            aCoder.encodeObject(distance, forKey: "distance")
            aCoder.encodeObject(restGas, forKey: "restGas")
            aCoder.encodeObject(bodyLevel, forKey: "bodyLevel")
            aCoder.encodeObject(engineStatus, forKey: "engineStatus")
            aCoder.encodeObject(transmissionStatus, forKey: "transmissionStatus")
            aCoder.encodeObject(light, forKey: "light")
            aCoder.encodeObject(cityId, forKey: "cityId")
            aCoder.encodeObject(carType, forKey: "carType")
		}
		
		required init?(coder aDecoder: NSCoder) {
			self.name   = aDecoder.decodeObjectForKey("name") as? String
			self.model  = aDecoder.decodeObjectForKey("model") as! String
			self.carNum = aDecoder.decodeObjectForKey("carnum") as! String
		}
	}
	
	
	//MARK: - 订单信息
	class OrderInfo: NSObject, NSCoding {
		var id: String!		//orderid
		var time: String!	//下订单的时间
		var reserveTime: String!		//预约时间
        var price: Double!  //价格
        var volume: Int!//汽油量
        var type: String!//汽油类型
        var station: String!//加油站名称
        
		
		init(id: String!, time: String!, reserveTime: String!, price: Double!, volume: Int!, type: String!, station: String!) {
            self.id          = id
            self.time        = time
            self.reserveTime = reserveTime
            self.price       = price
            self.volume      = volume
            self.type        = type
            self.station     = station
		}
        
		func encodeWithCoder(aCoder: NSCoder) {
			aCoder.encodeObject(id, forKey: "id")
			aCoder.encodeObject(time, forKey: "time")
			aCoder.encodeObject(reserveTime, forKey: "reserveTime")
		}
		
		required init?(coder aDecoder: NSCoder) {
			self.id          = aDecoder.decodeObjectForKey("id") as! String
			self.time        = aDecoder.decodeObjectForKey("time") as! String
			self.reserveTime = aDecoder.decodeObjectForKey("reserveTime") as! String
		}
	}
	
	
	//MARK: - UserInfo方法
	//编解码
	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(name, forKey: "name")
		aCoder.encodeObject(face, forKey: "face")
		aCoder.encodeObject(phone, forKey: "phone")
		aCoder.encodeObject(carInfo, forKey: "carinfo")
		aCoder.encodeObject(orderInfo, forKey: "orders")
        aCoder.encodeObject(isLogin, forKey: "isLogin")
	}
	
	required public init?(coder aDecoder: NSCoder) {
        self.name      = aDecoder.decodeObjectForKey("name") as! String
        self.face      = aDecoder.decodeObjectForKey("face") as? String
        self.phone     = aDecoder.decodeObjectForKey("phone") as! String
        self.carInfo   = aDecoder.decodeObjectForKey("carinfo") as? [CarInfo]
        self.orderInfo = aDecoder.decodeObjectForKey("orders") as? [OrderInfo]
        self.isLogin   = aDecoder.decodeObjectForKey("isLogin") as! Bool
	}
	
    //初始化
    override init() {
        self.name = ""
        self.phone = ""
    }
    
    
	//MARK: - 数据操作
    //更新基本用户信息
    func update(phoneNum num: String?, completionHandler action: (() -> Void)?) {
        PostWithInterface(service: "user/info", parameters: ["phone": (num == nil) ? self.phone : num])
			.responseJSON(completionHandler: { (res) in
				if res.result.isSuccess {
					if let value = res.result.value {
						let json = JSON(value)
                        
                        self.name  = json["user_name"].stringValue
                        self.face  = json["user_face"].stringValue
                        self.phone = json["user_phone"].stringValue
						
						action?()
					}
				}
			})
	}
	
    //更新汽车与订单信息
	func update(withType type: UpdateType, completionHandler action: () -> Void) {
		
		switch type {
		case .Car:
			PostWithInterface(service: "car/info", parameters: nil)
				.responseJSON(completionHandler: { (res) in
					if res.result.isSuccess {
						if res.result.value != nil {
							let json = JSON(res.result.value!)
							print(json)
							//初始化车辆数组
                            (self.carInfo == nil) ? self.carInfo = [CarInfo]() : self.carInfo?.removeAll()
							
							for carJson in json.arrayValue {
								let car = CarInfo(
									name: carJson["car_name"].string,
									branch: carJson["car_branch"].stringValue,
									logo: carJson["car_logo"].stringValue,
									model: carJson["car_scale"].stringValue,
									image: carJson["car_image"].stringValue,
									carNum: carJson["car_plate"].stringValue,
									engineNum: carJson["car_engine_number"].stringValue,
									//FIXME: - 车架号字段未指定
									classNum: carJson[""].stringValue,
									distance: carJson["car_mileage"].doubleValue,
									restGas: carJson["car_petrol"].doubleValue,
									bodyLevel: [carJson["car_doors"].intValue, carJson["car_seats"].intValue],
									engineStatus: carJson["car_engine_con"].intValue,
									transmissionStatus: carJson["car_amt_con"].intValue,
									light: carJson["car_lamp_con"].intValue,
									//FIXME: - 城市编号字段未指定
									cityId: carJson[""].intValue,
									//FIXME: - 汽车类型字段未指定
									carType: carJson[""].stringValue)
								
								self.carInfo!.append(car)
							}
							
							//执行回调
							action()
						}
					}
					else {
						print(res.result.error)
					}
				})
			
		case .Order:
			PostWithInterface(service: "order/info", parameters: nil)
				.responseJSON(completionHandler: { (res) in
					if res.result.isSuccess {
						if let value = res.result.value {
							let json = JSON(value)
                            
                            print(json)
                            
                            //初始化订单数组
                            (self.orderInfo == nil) ? self.orderInfo = [OrderInfo]() : self.orderInfo?.removeAll()
                            
                            for orderJson in json.arrayValue {
                                let order = OrderInfo(
                                    id: orderJson["order_id"].stringValue,
                                    time: orderJson["time"].stringValue,
                                    reserveTime: orderJson["reservetime"].stringValue,
                                    price: orderJson["cost"].doubleValue,
                                    volume: orderJson["order_petrol"].intValue,
                                    type: orderJson["type"].stringValue,
                                    station: orderJson["order_station"].stringValue)
                                
                                self.orderInfo!.append(order)
                            }
                            
                            //执行回调
                            action()
						}
                    } else {
                        print(res.result.error)
                        print(res.request?.HTTPBody)
                    }
				})
		}
	}
}