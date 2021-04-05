//
//  MainStore.swift
//  Sortify
//
//  Created by Coskun Deniz on 11/02/2021.
//

import Foundation
import Combine
import RxStore


class AppStore: RxStore {
    let loadingState = RxStore.State(Loading.initialState)
    let tracksState = RxStore.State(Tracks.initialState)
    let playlistsState = RxStore.State(Playlists.initialState)
    let playlistTracksState = RxStore.State(PlaylistTracks.initialState)
    let user = RxStore.State(User.initalState)
}



extension AppStore {
    static let shared =
        AppStore()
        .registerReducer(for: \.tracksState, Tracks.reducer)
        .registerReducer(for: \.playlistsState, Playlists.reducer)
        .registerReducer(for: \.playlistTracksState, PlaylistTracks.reducer)
        .registerReducer(for: \.loadingState, Loading.reducer)
        .registerReducer(for: \.user, User.reducer)
        .registerEffects([Playlists.Effects.getPlaylists,
                          PlaylistTracks.Effects.getPlaylistTracks,
                          PlaylistTracks.Effects.reorderPlaylistTrack,
                          PlaylistTracks.Effects.reorderPlaylistTrackSuccess,
                          PlaylistTracks.Effects.reloadPlaylistTracks,
                          PlaylistTracks.Effects.cancelPlaylistReordering,
                          User.loadUserEffect
        ])
        .initialize()
}




func getPlaylistTracks(playlistId: String) -> (AppStore) -> AnyPublisher<[Spotify.Track], Never> {
    return AppStore.createSelector(path: \.tracksState, path2: \.playlistTracksState) { tracksState, playlistTracks -> [Spotify.Track] in
        let trackIds = playlistTracks[playlistId] ?? []
        let tracks = trackIds.compactMap({tracksState[$0]})
        return tracks
    }
}


func getOwnPlaylists() -> (AppStore) -> AnyPublisher<[Spotify.Playlist],Never> {
    AppStore.createSelector(path: \.user, path2: \.playlistsState) { user, playlists in
        if let user = user {
            return playlists.filter {$0.owner.id == user.id}
        }
        return []
    }
}
