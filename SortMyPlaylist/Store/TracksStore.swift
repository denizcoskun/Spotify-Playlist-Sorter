//
//  Tracks.swift
//  Sortify
//
//  Created by Coskun Deniz on 11/02/2021.
//

import Foundation
import Combine
import RxStore

struct TracksStore {
    typealias State = [String: Spotify.Track]
    
    static let initialState: State = [:]
    
    
    static func reducer(state: State, action: RxStoreAction) -> State {
        switch action {
        case PlaylistTracksStore.Action.LoadPlaylistTracksSuccess(_, let newTracks):
            var newState = state
            newTracks.forEach{ newTrack in newState[newTrack.id] = newTrack }
            return newState
        default:
            return state
        }
    }
}


