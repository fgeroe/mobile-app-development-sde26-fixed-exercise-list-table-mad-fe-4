//
//  MADApp.swift
//  MAD
//
//  Created by Fabian Gerö on 21.09.26.
//

import SwiftUI

@main
struct MADApp: App {
    private let networkingService = NetworkingService()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                LoginView(networkingService: networkingService)
            }
        }
    }
}
