//
//  AppStore+Playlists.swift
//  Sortify
//
//  Created by Coskun Deniz on 05/04/2021.
//

import Foundation
import RxStore
import Combine


extension AppStore {
    enum Playlists {
        typealias State = [Spotify.Playlist]
        
        static let initialState: State = []
        
        enum Action {
            struct LoadPlaylists: RxStoreAction{}
            struct LoadPlaylistsSuccess: RxStoreAction {
                let payload: [Spotify.Playlist]
            }
            struct LoadPlaylistsFailure: RxStoreAction {
                let payload: Error
            }
        }
        
        static func reducer(state: State, action: RxStoreAction) -> State {
            switch action {
            case let action as Action.LoadPlaylistsSuccess:
                return action.payload
            default:
                return state
            }
        }
        
        enum Effects {
            static let getPlaylists = AppStore.createEffect(Action.LoadPlaylists.self) {_, action in
                return SpotifyWebApi.shared
                    .getPlaylists()
                    .map{Action.LoadPlaylistsSuccess(payload: $0)}
                    .catch({ error in Just(Action.LoadPlaylistsFailure(payload: error)) })
                    .eraseToAnyPublisher()
            }
        }
    }
}
