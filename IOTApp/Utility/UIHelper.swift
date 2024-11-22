//
//  UIHelper.swift
//  IOTApp
//
//  Created by Thushantha Fernando on 17/11/2024.
//

import UIKit

enum UIHelper {
    
    static func createSFImage(image: UIImage, color: UIColor, imageSize: CGFloat, weight: UIImage.SymbolWeight) -> UIImage {
        let boldConfig = UIImage.SymbolConfiguration(pointSize: imageSize, weight: weight)
        let finalImage = image.withConfiguration(boldConfig).withRenderingMode(.alwaysOriginal).withTintColor(color)
        
        return finalImage
    }
}
