//
//  newViewController.swift
//  completeTableView
//
//  Created by Amy on 16/5/21.
//  Copyright © 2016年 Amy. All rights reserved.
//

import UIKit

class newViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIScrollViewDelegate ,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate{
    var ctrlnames:[String]?
    var detail:[String]?
     var tmpString: String = String()
    // var tableView:UITableView?
    
    @IBOutlet weak var changeimage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    override func loadView() {
        super.loadView()
       
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //初始化数据，这一次数据，我们放在属性列表文件里
        self.ctrlnames =  NSArray(contentsOfFile:
            NSBundle.mainBundle().pathForResource("infoList", ofType:"plist")!) as? Array
        self.detail =  NSArray(contentsOfFile:
            NSBundle.mainBundle().pathForResource("dataList", ofType:"plist")!) as? Array
       

        print(self.ctrlnames)
        
        //创建表视图
//        
        tableView.delegate = self
        tableView.dataSource = self
//        //创建一个重用的单元格
//        tableView.registerClass(UITableViewCell.self,
//                                forCellReuseIdentifier: "SwiftCell")
        
       
        
        //setLayoutOfWidget()
       
    }
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        setLayoutOfWidget()
//    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setLayoutOfWidget()

    }
  
    //只有一个分区
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
        //返回表格行数（也就是返回控件数）
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ctrlnames!.count
    }
    
    //创建各单元显示内容(创建参数indexPath指定的单元）
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell
    {
        //为了提供表格显示性能，已创建完成的单元需重复使用
        let identify:String = "SwiftCell"
        //同一形式的单元格重复使用，在声明时已注册
        let cell = tableView.dequeueReusableCellWithIdentifier(identify,
                                                               forIndexPath: indexPath) as UITableViewCell
    
        
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.textLabel?.text = self.ctrlnames![indexPath.row]
        cell.detailTextLabel?.text = self.detail![indexPath.row]
        return cell
    }
    
    // UITableViewDelegate 方法，处理列表项的选中事件
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.tableView!.deselectRowAtIndexPath(indexPath, animated: true)
        
//                let itemString = self.ctrlnames![indexPath.row]
//        
//                let alertController = UIAlertController(title: "提示!",
//                                                        message: "你选中了【\(itemString)】", preferredStyle: .Alert)
//                let okAction = UIAlertAction(title: "确定", style: .Default,handler: nil)
//                alertController.addAction(okAction)
//                self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    
    
    func setLayoutOfWidget()
    {
        //调整头像的大小和位置
        changeimage.frame = CGRectMake(250*SCALE_WIDTH, 150*SCALE_HEIGHT,140*SCALE_WIDTH, 140*SCALE_WIDTH)
        changeimage.layer.cornerRadius=changeimage.frame.height/2
        //		print(140*SCALE_WIDTH)
        changeimage.clipsToBounds      = true
        

        
        //为头像添加点击事件
        changeimage.userInteractionEnabled=true
        let userIconActionGR = UITapGestureRecognizer()
        userIconActionGR.addTarget(self, action: #selector(selectIcon))
        changeimage.addGestureRecognizer(userIconActionGR)
        
        //从文件读取用户头像
        let fullPath = ((NSHomeDirectory() as NSString) .stringByAppendingPathComponent("Documents") as NSString).stringByAppendingPathComponent("photo.xcassets")
        //可选绑定,若保存过用户头像则显示之
        if let savedImage = UIImage(contentsOfFile: fullPath){
            self.changeimage.image = savedImage
        }
        
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
        self.changeimage.image = savedImage
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

    
    
    
    
       override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
}
