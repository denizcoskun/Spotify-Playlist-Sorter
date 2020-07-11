//
//  LoadingState.swift
//  Sortify
//
//  Created by Coskun Deniz on 11/02/2021.
//

import Foundation
import RxStore

struct LoadingStore {
    struct State: RxStoreState {
        let playlist: Bool
        let tracks: Bool
        let login: Bool
        init(playlist: Bool = false, tracks: Bool = false, login: Bool = false) {
            self.playlist = playlist
            self.tracks = tracks
            self.login = login
        }

    }
    

    
    static func reducer(state: State, action: RxStoreAction) -> State {

        switch action {
        case PlaylistsStore.Action.LoadPlaylists, PlaylistsStore.Action.LoadPlaylistsFailure:
            return State(playlist:true, tracks:state.tracks, login:state.login)
        case PlaylistsStore.Action.LoadPlaylistsSuccess(_):
            return State(playlist:false, tracks:state.tracks, login:state.login)
        case PlaylistTracksStore.Action.LoadPlaylistTracks(_):
            return State(playlist:state.playlist, tracks:true, login:state.login)
        case PlaylistTracksStore.Action.LoadPlaylistTracksSuccess(_,_), PlaylistTracksStore.Action.LoadPlaylistTracksFailure:
            return State(playlist:state.playlist, tracks:false, login:state.login)
        default:
            return state
        }
    }
}
