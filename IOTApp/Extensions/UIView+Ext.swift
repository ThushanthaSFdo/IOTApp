//
//  UIView+Ext.swift
//  IOTApp
//
//  Created by Thushantha Fernando on 17/11/2024.
//

import UIKit

extension UIView {
    
    func addSubviews(_ views: UIView...) {
        for view in views { addSubview(view) }
    }
    
}
