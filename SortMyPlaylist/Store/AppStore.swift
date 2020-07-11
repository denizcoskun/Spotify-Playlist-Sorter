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
    let loadingState = RxStoreSubject(LoadingStore.State())
    let tracksState = RxStoreSubject(TracksStore.initialState)
    let playlistsState = RxStoreSubject(PlaylistsStore.initialState)
    let playlistTracksState = RxStoreSubject(PlaylistTracksStore.initialState)
}



extension AppStore {
    static let shared =
        AppStore()
        .registerReducer(for: \.loadingState, reducer: LoadingStore.reducer)
        .registerReducer(for: \.tracksState, reducer: TracksStore.reducer)
        .registerReducer(for: \.playlistsState, reducer: PlaylistsStore.reducer)
        .registerReducer(for: \.playlistTracksState, reducer: PlaylistTracksStore.reducer)
        .registerEffects([PlaylistsEffects.getPlaylists,
                          PlaylistTracksEffects.getPlaylistTracks,
                          PlaylistTracksEffects.reorderPlaylistTrack,
                          PlaylistTracksEffects.reorderPlaylistTrackSuccess,
        ])
        .initialize()
}



