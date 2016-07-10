//
//  RouteAnnotaion.swift
//  CarManagement
//
//  Created by zhy on 16/5/9.
//  Copyright © 2016年 随便. All rights reserved.
//

import UIKit

class RouteAnnotation: BMKPointAnnotation {
	
	var type: Int!///<0:起点 1：终点 2：公交 3：地铁 4:驾乘 5:途经点
	var degree: Int!
	
	override init() {}
	
	init(type: Int, degree: Int) {
		self.type = type
		self.degree = degree
	}
}
