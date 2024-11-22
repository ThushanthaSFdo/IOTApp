//
//  IOTError.swift
//  IOTApp
//
//  Created by Thushantha Fernando on 16/11/2024.
//

import Foundation

enum IOTError: String, Error {
    case fileNotFound = "JSON File not found"
    case dataInitializationError = "Data initialisation Error"
    case decodeError = "Data decoding is having a fault. Please try again"
    
    case unableToSaveUser = "There was an error saving user information"
    case noUser = "No saved user is available"
    case unableToRemoveUser = "There was an error removing the user"
    case unableToRetrieveUser = "There was an error getting the User Information"
}

enum JSONParseError: Error {
    case fileNotFound
    case dataInitialisation(error: Error)
    case decoding(error: Error)
}

