//
//  ConfirmViewController.swift
//  CarManagement
//
//  Created by zhy on 16/4/11.
//  Copyright © 2016年 随便. All rights reserved.
//

import UIKit

class ConfirmViewController: UIViewController {
    @IBOutlet weak var getIdentifyingCode: UIButton!
    @IBOutlet weak var confirmPasswordText: UITextField!
    
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var identifyingNumberText: UITextField!
    @IBOutlet weak var phioneNumberText: UITextField!
    @IBOutlet weak var register: UIButton!
    @IBOutlet weak var confirmPassword: UILabel!
    @IBOutlet weak var password: UILabel!

    @IBOutlet weak var identifyingCode: UILabel!
    @IBOutlet weak var phioneNumber: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    override func viewDidAppear(animated: Bool) {
        self.setLayoutOfWidget()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setLayoutOfWidget()
    }

    func setLayoutOfWidget()
    {//手机号的大小和位置
        phioneNumber.frame =
        CGRectMake(30*SCALE_WIDTH, 30*SCALE_HEIGHT, 100, 50)
        phioneNumber.font = UIFont.systemFontOfSize(17)
        phioneNumber.textColor = UIColor.darkGrayColor()
        
        //验证码的大小和位置
        identifyingCode.frame =
            CGRectMake(30*SCALE_WIDTH, 100*SCALE_HEIGHT, 100, 50)
        identifyingCode.font = UIFont.systemFontOfSize(17)
        identifyingCode.textColor = UIColor.darkGrayColor()
        //密码的大小和位置
        password.frame =
            CGRectMake(30*SCALE_WIDTH, 170*SCALE_HEIGHT, 100, 50)
        password.font = UIFont.systemFontOfSize(17)
        password.textColor = UIColor.darkGrayColor()
  
        //确认密码的大小和位置
        confirmPassword.frame =
            CGRectMake(30*SCALE_WIDTH, 240*SCALE_HEIGHT, 100, 50)
        confirmPassword.font = UIFont.systemFontOfSize(17)
        confirmPassword.textColor = UIColor.darkGrayColor()
        //手机号输入框的大小和位置
        phioneNumberText.frame =
            CGRectMake(150*SCALE_WIDTH, 50*SCALE_HEIGHT, 200, 30)
        
        phioneNumberText.placeholder = "请输入注册手机号"
       phioneNumberText.clearButtonMode=UITextFieldViewMode.WhileEditing
        //验证码输入框的大小和位置
        identifyingNumberText.frame =
            CGRectMake(150*SCALE_WIDTH, 120*SCALE_HEIGHT, 200, 30)
        
        identifyingNumberText.placeholder = "请输入验证码"
         identifyingNumberText.clearButtonMode=UITextFieldViewMode.WhileEditing
        //密码输入框的大小和位置
        passwordText.frame =
            CGRectMake(150*SCALE_WIDTH, 190*SCALE_HEIGHT, 200, 30)
        passwordText.placeholder = "请输入密码"
        passwordText.clearButtonMode=UITextFieldViewMode.WhileEditing

        //确认密码输入框的大小和位置
        confirmPasswordText.frame =
            CGRectMake(150*SCALE_WIDTH, 260*SCALE_HEIGHT, 200, 30)
        confirmPasswordText.placeholder = "请确认密码"
        
        confirmPasswordText.clearButtonMode=UITextFieldViewMode.WhileEditing

        //验证吗的大小和位置
        
        getIdentifyingCode.frame =
        CGRectMake(150*SCALE_WIDTH+200, 30*SCALE_HEIGHT, 100, 50)
        //注册的大小和位置
        register.frame =
            CGRectMake(30*SCALE_WIDTH,
                       360*SCALE_HEIGHT, SCREEN_WIDTH-60*SCALE_WIDTH, 80*SCALE_HEIGHT)
        register.layer.cornerRadius=register.frame.height/2
        register.clipsToBounds      = true
    }
   
    
    
    
    var remainingSeconds: Int = 0 {
        willSet {
            getIdentifyingCode.setTitle("\(newValue)秒后重新获取", forState: .Normal)
            
            if newValue <= 0 {
                getIdentifyingCode.setTitle("重新获取验证码", forState: .Normal)
                isCounting = false
            }
        }
    }
    var countdownTimer: NSTimer?
    
    var isCounting = false {
        willSet {
            if newValue {
//                countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTime", userInfo: nil, repeats: true)
                countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
                
                remainingSeconds = 60
               // getIdentifyingCode.backgroundColor = UIColor.lightGrayColor()
            } else {
                countdownTimer?.invalidate()
                countdownTimer = nil
                
               
            }
            
            getIdentifyingCode.enabled = !newValue
        }
    }
    func updateTime(timer: NSTimer) {
        // 计时开始时，逐秒减少remainingSeconds的值
        remainingSeconds -= 1
    }
    
    @IBAction func Actionget(sender: AnyObject) {
        print(1)
        isCounting = true
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
