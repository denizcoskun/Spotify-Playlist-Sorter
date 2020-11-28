//
//  AuthenticatedView.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 11/07/2020.
//

import SwiftUI

struct AuthenticatedView: View {
    @EnvironmentObject var appState: AppStore
    var body: some View {
        PlaylistListView().onAppear(
            perform: self.appState.loadUserAndOwnPlaylists
        )
    }
}

struct AuthenticatedView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticatedView().environmentObject(AppStore()).edgesIgnoringSafeArea(.all)
    }
}
