//
//  SpotifyAuthService.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 16/08/2020.
//

import Combine
import Foundation

extension UserDefaults {
    @objc dynamic var accessToken: String {
        return string(forKey: "accessToken") ?? ""
    }
}

class SpotifyAuthService: ObservableObject {
    @Published var accessToken = ""
    @Published var refreshToken = ""
    @Published var expirationDate = Date()
    var cancellable: Cancellable?
    static let shared = SpotifyAuthService()

    lazy var loggedIn = {
        Timer.publish(every: 1, on: .main, in: .default)
            .autoconnect()
            .map { _ -> Bool in
                if self.accessToken.isEmpty {
                    return false
                }
                return (self.expirationDate + TimeInterval(-10 * 60.0)) > Date()
            }
    }()
}
