//
//  Scan2DCodeViewController.swift
//  CarManagement
//
//  Created by zhy on 16/5/21.
//  Copyright © 2016年 随便. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON


class Scan2DCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var _statusLabel: UILabel!
    
    var _captureSession:AVCaptureSession?
    var _videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var _qrCodeFrameView:UIView?
    
    //支持的二维码类型
    let _supportedBarCodes = [AVMetadataObjectTypeQRCode,
                             AVMetadataObjectTypeCode128Code,
                             AVMetadataObjectTypeCode39Code,
                             AVMetadataObjectTypeCode93Code,
                             AVMetadataObjectTypeUPCECode,
                             AVMetadataObjectTypePDF417Code,
                             AVMetadataObjectTypeEAN13Code,
                             AVMetadataObjectTypeAztecCode]
    

    //MARK: - 预加载
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //设置状态栏
        _statusLabel.layer.cornerRadius = 10
        _statusLabel.layer.borderWidth  = 0.5
        _statusLabel.layer.borderColor  = UIColor ( red: 0.7556, green: 0.7556, blue: 0.7556, alpha: 1.0 ).CGColor
        _statusLabel.clipsToBounds      = true
        
        //初始化图像设备
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)//视频
        
        do {
            //初始化视频输入流
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            //初始化图像捕获任务对象
            _captureSession = AVCaptureSession()
            //添加输入流
            _captureSession?.addInput(input)
            
            //初始化输出对象
            let output = AVCaptureMetadataOutput()
            //作为输出设备
            _captureSession?.addOutput(output)
            
            //设置输出代理，设置主线程处理回调操作
            output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            //设置输出类型，即支持的二维码类型
            output.metadataObjectTypes = _supportedBarCodes
            
            //初始化视频显示层，并作为根试图的sublayer添加
            _videoPreviewLayer = AVCaptureVideoPreviewLayer(session: _captureSession)//指定处理任务对象
            
            _videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill//自适应
            _videoPreviewLayer?.frame        = view.layer.bounds//全屏
            
            view.layer.addSublayer(_videoPreviewLayer!)
            
            //启动视频录制
            _captureSession?.startRunning()
            
            //将状态栏置顶
            view.bringSubviewToFront(_statusLabel)
            
            //设置指示二维码范围的方框
            _qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = _qrCodeFrameView {
                qrCodeFrameView.layer.borderColor  = UIColor.greenColor().CGColor
                qrCodeFrameView.layer.borderWidth  = 2
                qrCodeFrameView.layer.cornerRadius = 5
                
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
            
        } catch {
            print(error)
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }

    
    //MARK: - 处理视频设备输出的数据
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        //检查输出是否存在或为空
        if metadataObjects == nil || metadataObjects.count == 0 {
            _qrCodeFrameView?.frame = CGRectZero//二维码绿框尺寸为0
            _statusLabel.text = "尚未检测到二维码"
            return//退出处理块
        }
        
        //获取元数据
        let metadata = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        //若元数据的类型在支持的二维码类型之内
        if _supportedBarCodes.contains(metadata.type) {
            //获取二维码对象
            let code2DObj = _videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadata)
            //设置绿框
            _qrCodeFrameView?.frame = code2DObj!.bounds
            
            //处理二维码数据
            if metadata.stringValue != nil {
                //改变状态栏
                _statusLabel.text = "识别完成，正在跳转..."
                
                let json = JSON(metadata.stringValue)
                
                print(json)
                
                //打包json并传递到下一个控制器
//                self.performSegueWithIdentifier("AddCar", sender: PackStruct(struct: json))
            }
        }
    }
}
