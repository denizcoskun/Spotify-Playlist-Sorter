//
//  PlaylistDetailsView.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 11/07/2020.
//

import SwiftUI

struct PlaylistDetailsView: View {
    let playlist: Spotify.Playlist
    @StateObject var playlistModel = PlaylistModel()
    @State var tracks: [Spotify.Track] = []
    
    @State var tracksLoading = true
    var body: some View {
        return VStack(spacing: 0) {
            if !tracksLoading {
                if self.tracks.count > 0 {
                    TrackListView(playlistName: playlist.name).environmentObject(playlistModel)
                } else {
                    Text("No tracks found.").font(.title3).foregroundColor(.white)
                }
            } else {
                VStack {
                    Text("Getting the tracks...").padding(.top, 100).colorInvert()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        .frame(width: 50, height: 50)
                }.font(.title3)
            }
        }
        .onAppear {
            self.playlistModel.playlist = self.playlist
            AppStore.shared.dispatch(action: PlaylistTracksStore.Action.LoadPlaylistTracks(self.playlist))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .onReceive(AppStore.shared.loadingState) {
            print("tracksLoading", $0.tracks)
            tracksLoading = $0.tracks
        }
        .onReceive(AppStore.shared.mergeStates(statePath: \.tracksState, statePath2: \.playlistTracksState)) {tracksState, playlistTracks in
            self.tracks = tracksState.compactMap({$0.value})
            let trackIds = playlistTracks[self.playlist.id] ?? []
            let tracks = trackIds.compactMap({tracksState[$0]})
            self.tracks = tracks
            playlistModel.tracks = tracks
        }
        
    }
}

struct PlaylistDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PlaylistDetailsView(playlist: MockPlaylist).edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/ .all/*@END_MENU_TOKEN@*/)
        }
    }
}
