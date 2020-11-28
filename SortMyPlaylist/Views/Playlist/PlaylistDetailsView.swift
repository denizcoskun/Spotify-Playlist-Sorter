//
//  PlaylistDetailsView.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 11/07/2020.
//

import SwiftUI

struct PlaylistDetailsView: View {
    let playlist: Spotify.Playlist
    @EnvironmentObject var appState: AppStore
    @StateObject var playlistModel = PlaylistModel()
    @State var tracks: [Spotify.Track] = []

    var body: some View {
        return VStack(spacing: 0) {
            if tracks.count > 0 {
                TrackListView(playlistName: playlist.name).environmentObject(playlistModel)
            } else {
                VStack {
                    Text("Getting the tracks...").padding(.top, 100).colorInvert()
                    ProgressView()
                        .colorInvert()
                        .frame(width: 50, height: 50)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            self.playlistModel.playlist = self.playlist
            self.appState.loadPlaylistTracks(playlist: playlist)
        }
        .background(Rectangle()
            .fill(LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.App.capri, location: 0),
                    .init(color: Color.Spotify.black, location: 0.76),
                    .init(color: Color.Spotify.black, location: 1),
                ]),
                startPoint: UnitPoint(x: -0.67, y: -0.68),
                endPoint: UnitPoint(x: 1, y: 1)
            ))
            .edgesIgnoringSafeArea(.all))
        .onReceive(self.appState.objectWillChange) { _ in
            self.tracks = self.appState.playlistTracks(id: playlist.id)
            print("self.appState.$tracks count", self.tracks.count)
            playlistModel.tracks = self.appState.playlistTracks(id: playlist.id)
        }
    }
}

struct PlaylistDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PlaylistDetailsView(playlist: MockPlaylist).environmentObject(AppStore()).edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/ .all/*@END_MENU_TOKEN@*/)
        }
    }
}
