//
//  AppStore+Tracks.swift
//  Sortify
//
//  Created by Coskun Deniz on 05/04/2021.
//

import Foundation
import Combine
import RxStore


extension AppStore {
    enum Tracks {
        typealias State = [String: Spotify.Track]
        
        static let initialState: State = [:]
        
        static func reducer(state: State, action: RxStoreAction) -> State {
            switch action {
            case let action as PlaylistTracks.Action.LoadPlaylistTracksSuccess:
                var newState = state
                action.tracks.forEach{ newTrack in newState[newTrack.id] = newTrack }
                return newState
            default:
                return state
            }
        }
    }
}

