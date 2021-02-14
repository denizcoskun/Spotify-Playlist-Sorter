//
//  PlaylistTracksState.swift
//  Sortify
//
//  Created by Coskun Deniz on 11/02/2021.
//

import Foundation
import Combine
import RxStore

struct PlaylistTracksStore {
    typealias State =  [String: [String]]
    
    static let initialState: State = [:]
    
    enum Action: RxStoreAction {
        case LoadPlaylistTracks(Spotify.Playlist),
             ReloadPlaylistTracks(Spotify.Playlist),
             LoadPlaylistTracksSuccess(String, [Spotify.Track]),
             LoadPlaylistTracksFailure,
             ReorderPlaylistTracks(Spotify.Playlist, [EnumeratedSequence<[Spotify.Track]>.Element]),
             ReorderPlaylistTracksSuccess(Spotify.Playlist),
             ReorderPlaylistTracksFailure(Spotify.Playlist),
             CancelReorderPlaylistTracks
    }
    
    static func reducer(state: State, action: RxStoreAction) -> State {
        switch action {
        case Action.LoadPlaylistTracksSuccess(let playlistId, let playlists):
            var newState = state
            newState[playlistId] = playlists.map({$0.id})
            return newState
        default:
            return state
        }
    }
}

struct PlaylistTracksEffects {
    typealias Store = AppStore
    
    static let getPlaylistTracks: RxStore.Effect = {state, action in
        return action.flatMap { action -> AnyPublisher<RxStoreAction, Never> in

            switch action {
            case PlaylistTracksStore.Action.LoadPlaylistTracks(let playlist), PlaylistTracksStore.Action.ReloadPlaylistTracks(let playlist):
                return SpotifyWebApi.shared.getPlaylistTracks(playlist: playlist)
                    .map({PlaylistTracksStore.Action.LoadPlaylistTracksSuccess(playlist.id, $0)})
                    .catch({_ in
                        Just(PlaylistTracksStore.Action.LoadPlaylistTracksFailure)
                    })
                    .eraseToAnyPublisher()
            default:
                return Empty().eraseToAnyPublisher()

            }
        }.eraseToAnyPublisher()
    }
    

    static let reorderPlaylistTrack: RxStore.Effect = {store, action in
        return action.flatMap { action -> RxStore.ActionObservable in
            if case PlaylistTracksStore.Action.ReorderPlaylistTracks(let playlist, let enumeratedTracks) = action {
                return SpotifyWebApi.shared.updatePlaylistTrackOrders(playlistId: playlist.id, tracks: enumeratedTracks)
                    .map({_ in PlaylistTracksStore.Action.ReorderPlaylistTracksSuccess(playlist)})
                    .catch({_ in Just(PlaylistTracksStore.Action.ReorderPlaylistTracksFailure(playlist))
                    })
                    .prefix(untilOutputFrom: store.stream.filter({action in
                            if case PlaylistTracksStore.Action.CancelReorderPlaylistTracks = action {
                                return true
                            }
                            return false
                        })
                        .first()
                    )
                    .eraseToAnyPublisher()
            }
            return Empty().eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
    
    static let reorderPlaylistTrackSuccess: RxStore.Effect = {_, action in
        return action.map { action  in
            if case PlaylistTracksStore.Action.ReorderPlaylistTracksSuccess(let playlist) = action {
                return PlaylistTracksStore.Action.ReloadPlaylistTracks(playlist)
            }
            return RxStoreActions.Empty
        }.eraseToAnyPublisher()
    }
}



