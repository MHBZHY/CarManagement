//
//  ReceiveRemoteMessage.swift
//  CarManagement
//
//  Created by zhy on 16/5/21.
//  Copyright © 2016年 随便. All rights reserved.
//

import Foundation
import SwiftyJSON

public func SolveRemoteNotification(APNsNotification aps: [String : AnyObject]) {
    APNS_CONTENT = aps["content"] as? String
    APNS_BADGE   = aps["badge"] as? Int
    APNS_SOUND   = aps["sound"] as? String
    APNS_EXTRA   = JSON(aps["extra"] as! String)
}