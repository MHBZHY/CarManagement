//
//  ViewController.swift
//  CarManagement
//
//  Created by Amy on 16/4/15.
//  Copyright © 2016年 随便. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var getIdentify: UIButton!

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var identifyText: UITextField!
    @IBOutlet weak var identifyingNumber: UILabel!
    @IBOutlet weak var phioneNumberText: UITextField!
    @IBOutlet weak var phioneNumber: UILabel!
    var audioPlayer = AVAudioPlayer()
    //添加一个AVAudioPlayer类型的播放器变量
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //self.setLayoutOfWidget()
        print(SCREEN_HEIGHT)
       // playBgMusic()
        
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
    
    @IBAction func getIdentifier(sender: AnyObject) {
        isCounting = true
        
    }
    func setLayoutOfWidget()
    {
        //手机号的大小和位置
        phioneNumber.frame =       CGRectMake(30*SCALE_WIDTH, 50*SCALE_HEIGHT,100, 50)
       
        //调整验证码的大小和位置
        identifyingNumber.frame =
            CGRectMake(30*SCALE_WIDTH, 200*SCALE_HEIGHT,100, 50)
        //手机号输入框的大小和位置
        phioneNumberText.frame =
            CGRectMake(150*SCALE_WIDTH, 70*SCALE_HEIGHT,200, 30)
        phioneNumberText.placeholder = "请输入注册手机号"
         //验证码输入框的大小
        identifyText.frame =
        CGRectMake(150*SCALE_WIDTH, 220*SCALE_HEIGHT,200, 30)
        identifyText.placeholder = "请输入验证码"
        //获取验证码的大小和位置
        getIdentify.frame =
        CGRectMake(500*SCALE_WIDTH, 220*SCALE_HEIGHT,80, 30)
        getIdentify.layer.cornerRadius=getIdentify.frame.height/2
        getIdentify.clipsToBounds      = true
        //下一步的大小和位置
        nextButton.frame =
            CGRectMake(30*SCALE_WIDTH, 400*SCALE_HEIGHT,SCREEN_WIDTH-60*SCALE_WIDTH, 80*SCALE_HEIGHT)
        nextButton.layer.cornerRadius=nextButton.frame.height/2
        nextButton.clipsToBounds      = true
     }
    
    
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    var remainingSeconds: Int = 0 {
        willSet {
            getIdentify.setTitle("\(newValue)秒后重新获取", forState: .Normal)
            
            if newValue <= 0 {
                getIdentify.setTitle("重新获取验证码", forState: .Normal)
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
            
            getIdentify.enabled = !newValue
        }
    }
    func updateTime(timer: NSTimer) {
        // 计时开始时，逐秒减少remainingSeconds的值
        remainingSeconds -= 1
    }

//    func playBgMusic(){
//        
//        
//        
//        let musicPath = NSBundle.mainBundle().pathForResource("music", ofType: "mp3")
//        
//        //指定音乐路径
//        
//        let url = NSURL(fileURLWithPath: musicPath!)
//        
//        do {
//            audioPlayer = try AVAudioPlayer(contentsOfURL: url)
//        }
//        catch {}
//        
//        
//        audioPlayer.numberOfLoops = -1
//        
//        //设置音乐播放次数，-1为循环播放
//        
//        audioPlayer.volume = 1
//        
//        //设置音乐音量，可用范围为0~1
//        
//        audioPlayer.prepareToPlay()
//        
//        audioPlayer.play()
//        
//    }
    
    
    
}
