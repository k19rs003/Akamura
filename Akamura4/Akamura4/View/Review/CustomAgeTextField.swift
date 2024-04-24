//
//  ageTextField.swift
//  Akamura4-Swift
//
//  Created by Abe on R 3/11/08.
//

import Foundation
import UIKit

class CustomAgeTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
