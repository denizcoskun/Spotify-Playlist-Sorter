//
//  AppState.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 11/07/2020.
//

import Combine
import Foundation

class LoadingState {
    var playlist = false
    var tracks = false
}

class AppStore: ObservableObject {
    @Published var playlists: [Spotify.Playlist] = []
    @Published var playlistTracks = [String: [String]]()
    @Published var tracks = [String: Spotify.Track]()
    @Published var test = false
    @Published var user: Spotify.User?
    var anyCancellable: AnyCancellable?
    var api = SpotifyWebApi.shared
    @Published var rearrangingTrack = false
    var timer: AnyCancellable?
    @Published var tracksLoading = true

    func playlistTracks(id: String) -> [Spotify.Track] {
        let trackIds: [String] = playlistTracks[id] ?? []
        return trackIds.compactMap { trackId in
            self.tracks[trackId]
        }
    }

    func loadPlaylists() {
        anyCancellable = api.getPlaylists().sink(
            receiveCompletion: { _ in },
            receiveValue: { data in
                self.playlists = data.compactMap { $0 }
            }
        )
    }

    func loadUser() {
        anyCancellable = api.getUser().sink(
            receiveCompletion: { _ in },
            receiveValue: { user in self.user = user }
        )
    }

    func loadUserAndOwnPlaylists() {
        anyCancellable = api.getUser().flatMap { user -> AnyPublisher<[Spotify.Playlist], Error> in
            self.user = user
            return self.api.getPlaylists().map { $0.compactMap { $0 }.filter { $0.owner.id == user.id } }.eraseToAnyPublisher()
        }.sink(
            receiveCompletion: { _ in },
            receiveValue: { playlists in
                self.playlists = playlists
            }
        )
    }

    func loadPlaylistTracks(playlist: Spotify.Playlist) {
        tracksLoading = true
        anyCancellable = api.getPlaylistTracks(playlist: playlist)
            .sink(
                receiveCompletion: { error in
                    self.tracksLoading = false
                    
                },
                receiveValue: { data in
                    var tracks = self.tracks
                    data.forEach { track in
                        tracks[track.id] = track
                    }

                    self.tracks = tracks
                    self.playlistTracks[playlist.id] = data.map { $0.id }
                    print(self.playlistTracks[playlist.id]!)
                    self.tracksLoading = false
                    self.objectWillChange.send()
                }
            )
    }

    func updatePlaylistTracks(id: String, trackIds: [String]) {
        playlistTracks[id] = trackIds
        objectWillChange.send()
    }
}
