//
//  TextFieldDelegate.swift
//  CarManagement
//
//  Created by zhy on 16/5/16.
//  Copyright © 2016年 随便. All rights reserved.
//

import Foundation

class TextFieldDelegate: NSObject, UITextFieldDelegate {
	
//	override init() {}
	
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		let range = string.rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "0123456789\\b\\n"))
		
		if range == nil {
			return false
		}
		
		return true
	}
}