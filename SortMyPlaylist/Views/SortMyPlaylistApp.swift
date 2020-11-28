//
//  SortMyPlaylistApp.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 11/07/2020.
//

import SwiftUI

@main
struct SortMyPlaylistApp: App {
    var spotifyClient = SpotifyClient.shared
    var appState = AppStore()
    var spotifyWebApi = SpotifyWebApi.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(Color.Spotify.black)
                .environmentObject(spotifyClient)
                .environmentObject(appState)
                .onOpenURL { url in self.spotifyClient.startSession(url) }
        }
    }
}
