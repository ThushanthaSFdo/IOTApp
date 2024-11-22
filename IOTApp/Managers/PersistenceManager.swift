//
//  PersistenceManager.swift
//  IOTApp
//
//  Created by Thushantha Fernando on 20/11/2024.
//

import Foundation

enum PersistenceManager {
    static private let defaults = UserDefaults.standard
    
    enum Keys {
        static let user = "loggedUser"
    }
    
    // MARK: - Handle Users
    
    static func retrieveUser(completed: @escaping (Result<User, IOTError>) -> Void) {
        guard let userData = defaults.object(forKey: Keys.user) as? Data else {
            completed(.failure(.noUser))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let userinfo = try decoder.decode(User.self, from: userData)
            completed(.success(userinfo))
        } catch {
            completed(.failure(.unableToRetrieveUser))
        }
    }
    
    static func saveUser(user: User) -> IOTError? {
        do {
            let encoder = JSONEncoder()
            let encodedFavorites = try encoder.encode(user)
            defaults.set(encodedFavorites, forKey: Keys.user)
            return nil
        } catch {
            return .unableToSaveUser
        }
    }
    
    static func removeUser() -> IOTError? {
        guard let _ = defaults.object(forKey: Keys.user) as? Data else {
            return .noUser
        }
        
        defaults.removeObject(forKey: Keys.user)
        return nil
    }
}
