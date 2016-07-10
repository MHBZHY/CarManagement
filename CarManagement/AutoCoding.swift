//
//  AutoCoding.swift
//  CarManagement
//
//  Created by zhy on 16/5/29.
//  Copyright © 2016年 随便. All rights reserved.
//

import Foundation


public func autoEncoding(encoder coder: NSCoder, obj: AnyObject) {
    let mirror = Mirror(reflecting: obj)
    
    for case let (lable?, value) in mirror.children {
        coder.encodeObject(value as? AnyObject, forKey: lable)
    }
}

public func autoDecode(decoder coder: NSCoder, obj: NSObject) {
    let mirror = Mirror(reflecting: obj)
    
    for case let (label?, _) in mirror.children {
        obj.setValue(coder.decodeObjectForKey(label), forKey: label)
    }
}