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
        .registerReducer(for: \.loadingState, LoadingStore.reducer)
        .registerReducer(for: \.tracksState, TracksStore.reducer)
        .registerReducer(for: \.playlistsState, PlaylistsStore.reducer)
        .registerReducer(for: \.playlistTracksState, PlaylistTracksStore.reducer)
        .registerEffects([PlaylistsEffects.getPlaylists,
                          PlaylistTracksEffects.getPlaylistTracks,
                          PlaylistTracksEffects.reorderPlaylistTrack,
                          PlaylistTracksEffects.reorderPlaylistTrackSuccess,
        ])
        .initialize()
}




func getPlaylistTracks(playlistId: String) -> (AppStore) -> AnyPublisher<[Spotify.Track], Never> {
    return AppStore.createSelector(path: \.tracksState, path2: \.playlistTracksState, handler: { tracksState, playlistTracks -> [Spotify.Track] in
        let trackIds = playlistTracks[playlistId] ?? []
        let tracks = trackIds.compactMap({tracksState[$0]})
        return tracks
    })
}

