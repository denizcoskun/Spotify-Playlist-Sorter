//
//  ContentView.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 11/07/2020.
//

import SwiftUI

struct ContentView: View {
    @State var loggedIn = false
    @EnvironmentObject var spotifyClient: SpotifyClient
    init() {
        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    }

    var body: some View {
        NavigationView {
            Group {
                if loggedIn {
                    AuthenticatedView()
                } else {
                    LoginView().edgesIgnoringSafeArea(.all)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onReceive(SpotifyAuthService.shared.loggedIn, perform: {
            self.loggedIn = $0
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(SpotifyClient())
    }
}
