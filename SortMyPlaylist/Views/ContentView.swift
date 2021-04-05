//
//  ContentView.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 11/07/2020.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var spotifyClient: SpotifyClient
    init() {
        let navBarAppearance = UINavigationBar.appearance()
        
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
    }

    var body: some View {
        SubscriberView(SpotifyAuthService.shared.loggedIn) { loggedIn in
            NavigationView {
                Group {
                    if loggedIn {
                        AuthenticatedView()
                    } else {
                        LoginView().edgesIgnoringSafeArea(.all)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(SpotifyClient())
    }
}
