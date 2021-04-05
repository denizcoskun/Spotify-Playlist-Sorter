//
//  UserState.swift
//  Sortify
//
//  Created by Coskun Deniz on 05/04/2021.
//

import Foundation
import RxStore
import Combine

extension AppStore {
    enum User {
        typealias State = Spotify.User?
        static let initalState: State = nil
        
        enum Action {
            struct LoadUser: RxStoreAction {}
            struct LoadUserSuccess: RxStoreAction {
                let payload: Spotify.User
            }
            struct LoadUserFailure: RxStoreAction {
                let payload: Error
            }
        }
        
        static let reducer: RxStore.Reducer<State> = { state, action in
            switch action {
            case let action as Action.LoadUserSuccess:
                return action.payload
            default:
                return state
            }
        }
        
        static let loadUserEffect = AppStore.createEffect(Action.LoadUser.self) {_,_ in
            SpotifyWebApi.shared.getUser()
                .map({Action.LoadUserSuccess(payload: $0)})
                .catch({Just(Action.LoadUserFailure(payload: $0))})
                .eraseToAnyPublisher()
        }
    }
    
}
