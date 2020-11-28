//
//  SpotifyClient.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 11/07/2020.
//

import Combine
import Foundation
import SwiftUI

class SpotifyClient: NSObject, ObservableObject, SPTSessionManagerDelegate, SPTAppRemoteDelegate {
    @Published var session: SPTSession?

    static let shared = SpotifyClient()

    let authService = SpotifyAuthService.shared

    private let SpotifyClientID = "cbc821ef564e4be69b5a1ae6ea6583e9"
    private let SpotifyRedirectURI = URL(string: "sortmyplaylist://spotify-login-callback")!

    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURI)
        configuration.playURI = ""
        return configuration
    }()

    lazy var sessionManager: SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()

    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.delegate = self
        return appRemote
    }()

    func authenticate() {
        let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate, .userReadPrivate, .userReadEmail, .playlistModifyPrivate, .playlistModifyPublic]
        sessionManager.initiateSession(with: scope, options: .clientOnly)
    }

//    func connect() {
//        guard let date = self.expirationDate else {
//            self.accessToken = ""
//            return
//        }
//        if(date.timeIntervalSinceReferenceDate > Date().timeIntervalSinceReferenceDate) {
//            appRemote.connectionParameters.accessToken = self.accessToken
//            SPTAppRemote.checkIfSpotifyAppIsActive { isActive in
//                if isActive {
//                    self.appRemote.connect()
//                } else {
//                    self.appRemote.authorizeAndPlayURI("")
//                }
//            }
//        } else {
//            self.expirationDate = nil
//            return
//        }
//    }

    func startSession(_ url: URL) {
        sessionManager.application(UIApplication.shared, open: url, options: [:])
    }

    // MARK: SPTSessionManagerDelegate

    func sessionManager(manager _: SPTSessionManager, didInitiate session: SPTSession) {
        DispatchQueue.main.async {
            self.authService.accessToken = session.accessToken
            self.authService.refreshToken = session.refreshToken
            self.authService.expirationDate = session.expirationDate
            self.session = session
        }
        appRemote.connectionParameters.accessToken = session.accessToken
    }

    func sessionManager(manager _: SPTSessionManager, didFailWith _: Error) {}

    func appRemoteDidEstablishConnection(_: SPTAppRemote) {
        print("appRemoteDidEstablishConnection")
    }

    func appRemote(_: SPTAppRemote, didFailConnectionAttemptWithError _: Error?) {
        print("didFailConnectionAttemptWithError")
    }

    func appRemote(_: SPTAppRemote, didDisconnectWithError _: Error?) {
        print("didDisconnectWithError")
    }
}
