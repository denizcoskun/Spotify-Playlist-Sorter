//
//  AuthenticatedView.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 11/07/2020.
//

import SwiftUI

struct AuthenticatedView: View {
    var body: some View {
        PlaylistListView().onAppear(
            perform: {
                AppStore.shared.dispatch(action: PlaylistsStore.Action.LoadPlaylists)
            }
        )
    }
}

struct AuthenticatedView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticatedView().edgesIgnoringSafeArea(.all)
    }
}
