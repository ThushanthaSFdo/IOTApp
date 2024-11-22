//
//  IAAvatarImageView.swift
//  IOTApp
//
//  Created by Thushantha Fernando on 20/11/2024.
//

import UIKit

class IAAvatarImageView: UIImageView {
    let placeholderImage = Images.placeHolder
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(){
        layer.cornerRadius = 10
        clipsToBounds = true
        image = placeholderImage
        translatesAutoresizingMaskIntoConstraints = false
    }
}
