//
//  AppStore+PlaylistTracks.swift
//  Sortify
//
//  Created by Coskun Deniz on 05/04/2021.
//

import Foundation
import Combine
import RxStore


extension AppStore {
    enum PlaylistTracks {
        typealias State =  [String: [String]]
        
        static let initialState: State = [:]
        
        enum Action {
            struct LoadPlaylistTracks: RxStoreAction {
                let payload: Spotify.Playlist
            }
            struct ReloadPlaylistTracks: RxStoreAction {
                let payload: Spotify.Playlist
            }
            struct LoadPlaylistTracksSuccess: RxStoreAction {
                let playlistId: String
                let tracks: [Spotify.Track]
            }
            struct LoadPlaylistTracksFailure: RxStoreAction {}
            struct ReorderPlaylistTracks: RxStoreAction {
                let playlist: Spotify.Playlist
                let tracks: [EnumeratedSequence<[Spotify.Track]>.Element]
            }
            struct ReorderPlaylistTracksSuccess: RxStoreAction {
                let payload: Spotify.Playlist
            }
            struct ReorderPlaylistTracksFailure: RxStoreAction {
                let error: Error
            }
            struct CancelReorderPlaylistTracks: RxStoreAction {
                let payload: Spotify.Playlist
            }
        }
        
        static func reducer(state: State, action: RxStoreAction) -> State {
            switch action {
            case let action as Action.LoadPlaylistTracksSuccess:
                var newState = state
                newState[action.playlistId] = action.tracks.map({$0.id})
                return newState
            default:
                return state
            }
        }
        
        enum Effects {
            static let reloadPlaylistTracks = AppStore.createEffect(Action.ReloadPlaylistTracks.self) {_, action in
                Just(Action.LoadPlaylistTracks(payload: action.payload)).eraseToAnyPublisher()
            }
            
            static let getPlaylistTracks = AppStore.createEffect(Action.LoadPlaylistTracks.self) {_, action in
                return SpotifyWebApi.shared.getPlaylistTracks(playlist: action.payload)
                    .map({Action.LoadPlaylistTracksSuccess(playlistId: action.payload.id, tracks: $0)})
                    .catch({_ in
                        Just(Action.LoadPlaylistTracksFailure())
                    })
                    .eraseToAnyPublisher()
            }
            

            static let reorderPlaylistTrack = AppStore.createEffect(Action.ReorderPlaylistTracks.self) {store, action in
                return SpotifyWebApi.shared.updatePlaylistTrackOrders(playlistId: action.playlist.id, tracks: action.tracks)
                    .map({_ in Action.ReorderPlaylistTracksSuccess(payload: action.playlist)
                    })
                    .catch({Just(Action.ReorderPlaylistTracksFailure(error: $0))})
                    .prefix(untilOutputFrom:
                                store.actions
                                .filter({$0 is Action.CancelReorderPlaylistTracks})
                                .first()
                    )
                .eraseToAnyPublisher()
            }

            
            static let reorderPlaylistTrackSuccess = AppStore.createEffect(Action.ReorderPlaylistTracksSuccess.self) { _ , action in
                Just(Action.ReloadPlaylistTracks(payload: action.payload)).eraseToAnyPublisher()
            }
            
            static let cancelPlaylistReordering = AppStore.createEffect(Action.CancelReorderPlaylistTracks.self) { _ , action in
                Just(Action.LoadPlaylistTracks(payload: action.payload)).eraseToAnyPublisher()
            }

        }
    }
}
