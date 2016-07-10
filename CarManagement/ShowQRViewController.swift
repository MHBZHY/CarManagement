//
//  ShowQRViewController.swift
//  CarManagement
//
//  Created by zhy on 16/6/5.
//  Copyright © 2016年 随便. All rights reserved.
//

import UIKit

class ShowQRViewController: UIViewController {
    
    @IBOutlet weak var _qrImageView: UIImageView!
    
    var qrURL: String!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        SetImageView(_qrImageView, imageURL: qrURL, circle: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
