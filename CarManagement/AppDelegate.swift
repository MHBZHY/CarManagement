//
//  AppDelegate.swift
//  CarManagement
//
//  Created by zhy on 16/4/11.
//  Copyright © 2016年 随便. All rights reserved.
//

import UIKit
import SwiftyJSON


//服务器地址
let PUBLIC_URL        = "http://115.28.131.81/index.php"
//let PUBLIC_URL        = "http://localhost:8888"

//标识
let DEVICE_ID         = UIDevice.currentDevice().identifierForVendor?.UUIDString
let BUNDLE_IDENTIFIER = "com.suibian.CarManagement"

//设备尺寸
let SCREEN_WIDTH      = UIScreen.mainScreen().bounds.width
let SCREEN_HEIGHT     = UIScreen.mainScreen().bounds.height

//换算比例, iPhone 4.0" 设计适用
let SCALE_WIDTH       = SCREEN_WIDTH / 640
let SCALE_HEIGHT      = SCREEN_HEIGHT / 1136

//轻量缓存
let Cache             = NSUserDefaults.standardUserDefaults()

//百度地图ak
let AK_IOS            = "vA2AGuqiK3kLzoQFY2AePkvnbWa2YOdh"
let AK_WEB            = "2go6bEEgYVPDmmLWF0P7A7hdcVuEbDXI"

//加油站ak
let GAS_AK            = "bb7e5dd74a56ed6bf8cfeabe7d4ad605"

//推送消息
var APNS_CONTENT: String?
var APNS_BADGE: Int?
var APNS_SOUND: String?
var APNS_EXTRA: JSON?

//用户数据
var UserInfo: UserInfoModel!



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BMKGeneralDelegate {

	var window: UIWindow?
    
	var _mapManager: BMKMapManager?
	

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		
		//窗口背景颜色
		self.window?.backgroundColor = UIColor.whiteColor()
		
		//用户信息缓存
        UserInfo = (Cache.objectForKey("UserInfo") != nil) ? Cache.objectForKey("UserInfo") as! UserInfoModel : UserInfoModel()
        
        //假装登录
        PostWithInterface(service: "user/login", parameters: ["phone": "18401605721", "password": "a1s2d3"])
//            .responseJSON { (res) in
//                if res.result.isSuccess {
//                    UserInfo.isLogin = true
//                    UserInfo.phone = "a1s2d3"
//                    
//                    if let value = res.result.value {
//                        print(value)
//                    }
//                }
//                else {
//                    print(res.result.error)
//                }
//        }
            .responseString { (res) in
                if res.result.isSuccess {
                    UserInfo.isLogin = true
                    UserInfo.phone = "a1s2d3"
                    
                    if let value = res.result.value {
                        print(value)
                    }
                }
                else {
                    print(res.result.error)
                }
        }
        
		//启动百度地图
		_mapManager = BMKMapManager()
		
		if !_mapManager!.start(AK_IOS, generalDelegate: self) {
			print("stat failed!")
			
//			ShowAlertWindow(target: UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Map"), alertTitle: "警告", message: "地图初始化失败，请检查网络设置以及隐私定位设置", actionTitle: "我知道了")
			ShowAlertWindow(target: self.window!.rootViewController!, alertTitle: "警告", message: "地图初始化失败，请检查网络设置以及隐私定位设置", actionTitle: "我知道了")
		}
		ShowAlertWindow(target: self.window!.rootViewController!, alertTitle: "警告", message: "地图初始化失败，请检查网络设置以及隐私定位设置", actionTitle: "我知道了")
		
		
        
        //注册消息推送
//        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
//        
//        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        //极光推送
        JPUSHService.registerForRemoteNotificationTypes(UIUserNotificationType.Alert.rawValue | UIUserNotificationType.Badge.rawValue | UIUserNotificationType.Sound.rawValue, categories: nil)
		
        JPUSHService.setupWithOption(launchOptions)//无视此警告，存在plist
        
        //如果点击推送消息导致应用启动
        if let options = launchOptions {
            if let remote = options[UIApplicationLaunchOptionsRemoteNotificationKey] {
                SolveRemoteNotification(APNsNotification: remote["aps"] as! [String : AnyObject])
            }
        }
		
		return true
	}
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
//        NSLog("---Token---%@", String(deviceToken))
        //注册devicetoken
        JPUSHService.registerDeviceToken(deviceToken)
    }
	
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
//        print(userInfo)
        //接收消息
        SolveRemoteNotification(APNsNotification: userInfo["aps"] as! [String : AnyObject])
        
        JPUSHService.handleRemoteNotification(userInfo)
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        let alert = UIAlertController(title: "推送消息", message: userInfo["info"] as? String, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "好", style: .Default, handler: nil))
        
        window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }
    
	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		//退出时保存用户信息
		Cache.setObject(UserInfo, forKey: "UserInfo")
	}
}

