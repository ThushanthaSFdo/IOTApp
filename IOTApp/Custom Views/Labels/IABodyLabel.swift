//
//  IABodyLabel.swift
//  IOTApp
//
//  Created by Thushantha Fernando on 18/11/2024.
//

import UIKit

class IABodyLabel: UILabel {    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(textalignment: NSTextAlignment){
        self.init(frame: .zero)
        self.textAlignment = textalignment
    }
    
    private func configure(){
        textColor = AppColors.lightFontColor
        font = UIFont.preferredFont(forTextStyle: .body)
        adjustsFontForContentSizeCategory = true
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = 0.75
        lineBreakMode = .byWordWrapping
        translatesAutoresizingMaskIntoConstraints = false
    }
}
