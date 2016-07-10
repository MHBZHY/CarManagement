//
//  LoginViewController.swift
//  CarManagement
//
//  Created by zhy on 16/4/11.
//  Copyright © 2016年 随便. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class LoginViewController: UIViewController ,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var headImage: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var passwordImage: UIImageView!
    @IBOutlet weak var userText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var register: UIButton!
    @IBOutlet weak var forgetPassword: UIButton!
    var img :UIImageView!
    var sheet:UIAlertController!
    
    var sourceType = UIImagePickerControllerSourceType.PhotoLibrary //将sourceType赋一个初值类型，防止调用时不赋值出现崩溃
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.setLayoutOfWidget()
		
//		self.setLayoutOfWidget()
//        print(SCREEN_HEIGHT)
		
        
    }
    func keyboardHide(tapG:UITapGestureRecognizer){
        //整个view  结束编辑状态(方法一)
        self.view.endEditing(true)
        //单个输入框（方法二）
        self.passwordText.resignFirstResponder()
    }
    override func viewDidAppear(animated: Bool) {
//		super.viewWillAppear(animated)
		
//        self.setLayoutOfWidget()
    }
	
	override func viewWillAppear(animated: Bool) {
//		super.viewWillAppear(animated)
//		
//		self.setLayoutOfWidget()
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        let rootView = TPKeyboardAvoidingScrollView(frame: self.view.bounds);
        self.setLayoutOfWidget()
//        self.view.addSubview(rootView)
		
		
		
		let layer1 = CALayer()
		layer1.frame = CGRectMake(userImage.frame.minX, userText.frame.maxY + 10, userText.frame.maxX - userImage.frame.minX, 0.5)
		layer1.backgroundColor = UIColor ( red: 0.4706, green: 0.4706, blue: 0.4706, alpha: 1.0 ).CGColor
		
		self.view.layer.addSublayer(layer1)
		
		let layer2 = CALayer()
		layer2.frame = CGRectMake(passwordImage.frame.minX, passwordText.frame.maxY + 10, passwordText.frame.maxX - passwordImage.frame.minX, 0.5)
		layer2.backgroundColor = UIColor ( red: 0.4706, green: 0.4706, blue: 0.4706, alpha: 1.0 ).CGColor
		
		self.view.layer.addSublayer(layer2)
		
    }
    
    func setLayoutOfWidget()
    {
        //调整头像的大小和位置
        headImage.frame =       CGRectMake(250*SCALE_WIDTH, 150*SCALE_HEIGHT,140*SCALE_WIDTH, 140*SCALE_WIDTH)
        headImage.layer.cornerRadius=headImage.frame.height/2
//		print(140*SCALE_WIDTH)
        headImage.clipsToBounds      = true
        
        //为头像添加点击事件
        headImage.userInteractionEnabled=true
        let userIconActionGR = UITapGestureRecognizer()
        userIconActionGR.addTarget(self, action: #selector(selectIcon))
        headImage.addGestureRecognizer(userIconActionGR)
        
        //从文件读取用户头像
        let fullPath = ((NSHomeDirectory() as NSString) .stringByAppendingPathComponent("Documents") as NSString).stringByAppendingPathComponent("photo.xcassets")
        //可选绑定,若保存过用户头像则显示之
        if let savedImage = UIImage(contentsOfFile: fullPath){
            self.headImage.image = savedImage
        }
       
        //调整用户名图像的大小和位置
        userImage.frame =
        CGRectMake(90*SCALE_WIDTH, 330*SCALE_HEIGHT,30*SCALE_WIDTH, 30*SCALE_WIDTH)
        //调整密码图像的大小和位置
        passwordImage.frame =
            CGRectMake(90*SCALE_WIDTH, 432*SCALE_HEIGHT,30*SCALE_WIDTH, 30*SCALE_WIDTH)
        //调整用户名输入框的大小和位置
        userText.frame =
         CGRectMake(130*SCALE_WIDTH, 330*SCALE_HEIGHT,430*SCALE_WIDTH, 30*SCALE_HEIGHT)
		
        
        userText.placeholder="请输入用户名"
        
       userText.clearButtonMode = UITextFieldViewMode.WhileEditing
        //调整密码输入框的大小和位置
        passwordText.frame =
            CGRectMake(130*SCALE_WIDTH, 432*SCALE_HEIGHT,430*SCALE_WIDTH, 30*SCALE_HEIGHT)
        passwordText.placeholder="请输入密码"
		
        
        passwordText.clearButtonMode = UITextFieldViewMode.WhileEditing
        //调整登录按钮的大小和位置
        loginButton.frame =
        CGRectMake(90*SCALE_WIDTH, 558*SCALE_HEIGHT,460*SCALE_WIDTH, 80*SCALE_HEIGHT)
		
		print(loginButton.frame.height)
		print(80*SCALE_HEIGHT)
		
        loginButton.layer.cornerRadius=loginButton.frame.height/2
        loginButton.clipsToBounds      = true
        //忘记密码的大小和位置
        forgetPassword.frame =
            CGRectMake(90*SCALE_WIDTH, 688*SCALE_HEIGHT,100*SCALE_WIDTH, 30*SCALE_HEIGHT)
        forgetPassword.titleLabel?.font = UIFont.systemFontOfSize(12)
        forgetPassword.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
        //立即注册的大小和位置
        register.frame =
            CGRectMake(450*SCALE_WIDTH, 688*SCALE_HEIGHT,100*SCALE_WIDTH, 30*SCALE_HEIGHT)
        register.titleLabel?.font = UIFont.systemFontOfSize(12)
        register.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
    }
    
    //选择头像的函数
    func selectIcon(){
        let userIconAlert = UIAlertController(title: "请选择操作", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let chooseFromPhotoAlbum = UIAlertAction(title: "从相册选择", style: UIAlertActionStyle.Default, handler: funcChooseFromPhotoAlbum)
        userIconAlert.addAction(chooseFromPhotoAlbum)
        
        let chooseFromCamera = UIAlertAction(title: "拍照", style: UIAlertActionStyle.Default,handler:funcChooseFromCamera)
        userIconAlert.addAction(chooseFromCamera)
        
        let canelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel,handler: nil)
        userIconAlert.addAction(canelAction)
        
        self.presentViewController(userIconAlert, animated: true, completion: nil)
    }
    
    //从相册选择照片
    func funcChooseFromPhotoAlbum(avc:UIAlertAction) -> Void{
        let imagePicker = UIImagePickerController()
        //设置代理
        imagePicker.delegate = self
        //允许编辑
        imagePicker.allowsEditing = true
        //设置图片源
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        //模态弹出IamgePickerView
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    //拍摄照片
    func funcChooseFromCamera(avc:UIAlertAction) -> Void{
        let imagePicker = UIImagePickerController()
        //设置代理
        imagePicker.delegate = self
        //允许编辑
        imagePicker.allowsEditing=true
        //设置图片源
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        //模态弹出IamgePickerView
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    //UIImagePicker回调方法
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //获取照片的原图
        //let image = (info as NSDictionary).objectForKey(UIImagePickerControllerOriginalImage)
        //获得编辑后的图片
        let image = (info as NSDictionary).objectForKey(UIImagePickerControllerEditedImage)
        //保存图片至沙盒
        self.saveImage(image as! UIImage, imageName: "photo.xcassets")
        let fullPath = ((NSHomeDirectory() as NSString).stringByAppendingPathComponent("Documents") as NSString).stringByAppendingPathComponent("photo.xcassets")
        //存储后拿出更新头像
        let savedImage = UIImage(contentsOfFile: fullPath)
        self.headImage.image = savedImage
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    //MARK: - 保存图片至沙盒
    func saveImage(currentImage:UIImage,imageName:String){
        var imageData = NSData()
        imageData = UIImageJPEGRepresentation(currentImage, 0.5)!
        // 获取沙盒目录
        let fullPath = ((NSHomeDirectory() as NSString).stringByAppendingPathComponent("Documents") as NSString).stringByAppendingPathComponent(imageName)
        // 将图片写入文件
        imageData.writeToFile(fullPath, atomically: false)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func login(sender: AnyObject) {
        PostWithInterface(service: "Login", parameters: ["phone" : userText.text!, "password": passwordText.text!])
        .responseString { (res) in
            if res.result.isSuccess {
                if res.result.value! == "1" {
                    ShowAlertWindow(target: self, alertTitle: nil, message: "登录成功", actionTitle: "确定")
                }
                if res.result.value! == "0" {
                    ShowAlertWindow(target: self, alertTitle: nil, message: "登录失败", actionTitle: "确定")
                }
            }
        }
    }
}
