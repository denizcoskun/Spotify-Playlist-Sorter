//
//  LoginViewModel.swift
//  Sortify
//
//  Created by Coskun Deniz on 13/12/2020.
//

import Foundation
import Combine


class LoginViewModel: ObservableObject {
    var cancellable: AnyCancellable?
    let spotifyWebApi = SpotifyWebApi.shared
    
    
    func getAccessToken(code: String) {
        cancellable = spotifyWebApi.getAccessToken(autenticationCode: code).sink(receiveCompletion: {
            print($0)
        }, receiveValue: {
            print($0)
        })
    }
}
