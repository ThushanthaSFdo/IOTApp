//
//  User.swift
//  IOTApp
//
//  Created by Thushantha Fernando on 16/11/2024.
//

import Foundation

struct User: Codable {
    let username: String
    let name: String
    var location: String?
    var avatar: String?
}

struct UserAccount: Codable {
    let user: User
}
