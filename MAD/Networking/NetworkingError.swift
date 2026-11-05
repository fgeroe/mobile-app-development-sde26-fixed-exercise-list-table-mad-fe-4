//
//  NetworkingError.swift
//  MAD
//
//  Created by Fabian Gerö on 15.10.26.
//


import Foundation

nonisolated enum NetworkingError: Error {
    case serializationFailed(String)
    case invalidEmail
    case emailNotFound
    case wrongPassword
    case invalidCredentials
    case unauthenticated
    case permissionDenied
    case offline(String)
    case invalidResponseFormat
    case serverError(statusCode: Int, message: String?)
    case unexpected(String)

    var message: String {
        switch self {
        case .serializationFailed(let description):
            return "Your login data couldn't be prepared. \(description)"
        case .invalidEmail:
            return "Please enter a valid email address."
        case .emailNotFound:
            return "There's no account with this email address."
        case .wrongPassword:
            return "The password is incorrect. Please try again."
        case .invalidCredentials:
            return "The email or password is incorrect. Please try again."
        case .unauthenticated:
            return "Your session is no longer valid. Please log in again."
        case .permissionDenied:
            return "You don't have permission to load this data. Please log in again."
        case .offline(let description):
            return description
        case .invalidResponseFormat:
            return "The server sent a response that couldn't be read. Please try again later."
        case .serverError(let statusCode, let message):
            if let message {
                return "The server returned an error (\(statusCode)): \(message)"
            }
            return "The server returned an error (\(statusCode)). Please try again later."
        case .unexpected(let description):
            return description
        }
    }
}
