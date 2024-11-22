//
//  JSONSimulation.swift
//  IOTApp
//
//  Created by Thushantha Fernando on 20/11/2024.
//

import UIKit

enum JSONSimulation {
    
    static func getUserLogin(for username: String, and password: String) -> Bool{
        var success: Bool = false
        
        self.getUserInfo { result in
            
            switch result {
            case .success(let userinfo):
                if username == userinfo.username && password == "abcdef12" {
                    success = true
                }
            case .failure(let error):
                success = false
            }
        }
        
        print(success)
        return success
    }
    
    static func getUserInfo(completed: @escaping (Result<User, IOTError>) -> Void) {
        
        guard let url = Bundle.main.url(forResource: "User", withExtension: "json") else {
            return completed(.failure(.fileNotFound))
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
//            let UserInfo = try decoder.decode(User.self, from: data)
            
            let userInfo = try decoder.decode(UserAccount.self, from: data)
            completed(.success(userInfo.user))
        } catch {
            completed(.failure(.decodeError))
        }
    }
}
