//
//  UIButton+Setup.swift
//  BetaBit
//
//  Created by Piotr Dudek on 08/04/16.
//  Copyright © 2016 Piotr Dudek. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func setupRoundRect() {
        layer.cornerRadius = 5
        layer.shadowRadius = 3
        layer.shadowOffset = CGSizeMake(0, 2)
        layer.shadowOpacity = 0.5
    }
}
