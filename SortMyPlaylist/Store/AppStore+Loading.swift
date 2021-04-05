//
//  AppStore+Loading.swift
//  Sortify
//
//  Created by Coskun Deniz on 05/04/2021.
//

import Foundation
import Combine
import RxStore

extension AppStore {
    enum Loading {
        struct State: Equatable, Codable {
            let playlist: Bool
            let tracks: Bool
            let login: Bool
            let orderingTracks: Bool
            
            init(playlist: Bool = false, tracks: Bool = false, login: Bool = false, orderingTracks: Bool = false) {
                self.playlist = playlist
                self.tracks = tracks
                self.login = login
                self.orderingTracks = orderingTracks
            }
        }
        
        static let initialState = State()
        static func reducer(state: State, action: RxStoreAction) -> State {

            switch action {
            case _ as Playlists.Action.LoadPlaylists:
                return State(playlist:true, tracks:state.tracks, login:state.login, orderingTracks: state.orderingTracks)
            case _ as Playlists.Action.LoadPlaylistsSuccess,
                 _ as Playlists.Action.LoadPlaylistsFailure:
                return State(playlist:false, tracks:state.tracks, login:state.login, orderingTracks: state.orderingTracks)
            case _ as PlaylistTracks.Action.LoadPlaylistTracks:
                return State(playlist:state.playlist, tracks:true, login:state.login, orderingTracks: state.orderingTracks)
            case _ as PlaylistTracks.Action.LoadPlaylistTracksSuccess,
                 _ as PlaylistTracks.Action.LoadPlaylistTracksFailure:
                return State(playlist:state.playlist, tracks:false, login:state.login, orderingTracks: state.orderingTracks)
            case _ as PlaylistTracks.Action.ReorderPlaylistTracks:
                return State(playlist:state.playlist, tracks:state.tracks, login:state.login, orderingTracks: true)
            case _ as PlaylistTracks.Action.ReorderPlaylistTracksSuccess,
                 _ as PlaylistTracks.Action.ReorderPlaylistTracksFailure,
                 _ as PlaylistTracks.Action.CancelReorderPlaylistTracks:
                return State(playlist:state.playlist, tracks:state.tracks, login:state.login, orderingTracks: false)
            default:
                return state
            }
        }
    }

}
