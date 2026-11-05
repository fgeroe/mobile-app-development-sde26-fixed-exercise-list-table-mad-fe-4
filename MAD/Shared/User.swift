//
//  User.swift
//  MAD
//
//  Created by Fabian Gerö on 15.10.26.
//


import Foundation

nonisolated struct User: Codable, Hashable {
    let localId: String
    let email: String
    let displayName: String
    let idToken: String
    let registered: Bool
    let refreshToken: String
    let expiresIn: String
}
