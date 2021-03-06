//
//  PlaylistsState.swift
//  Sortify
//
//  Created by Coskun Deniz on 11/02/2021.
//

import Foundation
import Combine
import RxStore

struct PlaylistsStore {
    typealias State = [Spotify.Playlist]
    
    static let initialState: State = []
    
    enum Action: RxStoreAction {
        case LoadPlaylists,
             LoadPlaylistsSuccess([Spotify.Playlist]),
             LoadPlaylistsFailure(Error)
    }
    
    static func reducer(state: State, action: RxStoreAction) -> State {
        switch action {
        case Action.LoadPlaylistsSuccess(let playlists):
            return playlists
        default:
            return state
        }
    }
}


struct PlaylistsEffects {

    
    static let  getPlaylists: RxStore.Effect = { state, action in
        action.flatMap{action  -> RxStore.ActionObservable in
            if case PlaylistsStore.Action.LoadPlaylists = action {
                return SpotifyWebApi.shared
                    .getPlaylists()
                    .map{PlaylistsStore.Action.LoadPlaylistsSuccess($0)}
                    .catch({ error in Just(PlaylistsStore.Action.LoadPlaylistsFailure(error)) })
                    .eraseToAnyPublisher()
            }
            return Empty().eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}

