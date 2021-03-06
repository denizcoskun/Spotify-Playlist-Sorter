//
//  PlaylistDetailsView.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 11/07/2020.
//

import SwiftUI
import Combine
struct SortPlaylist {
    let by: Spotify.SortAttribute
    var order: Spotify.SortOrder
    static let empty = SortPlaylist(by: .none, order: .none)
}


struct PlaylistDetailsView: View {
    let playlist: Spotify.Playlist
        
    var body: some View {
        return VStack(spacing: 0) {
            
            SubscriberView(AppStore.shared.loadingState) {loadingState in
                let playlist$ = AppStore.shared.select(getPlaylistTracks(playlistId: playlist.id))
                if !loadingState.tracks {
                    SubscriberView(playlist$) { tracks in
                        Group {
                            if tracks.count > 0 {
                                TrackListView(tracks: tracks, playlistName: playlist.name)
                                    
                            } else {
                                Text("No tracks found.")
                                    .font(.title3)
                                    .foregroundColor(.white)
                            }
                        }
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
        }
        .onAppear {
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
            .edgesIgnoringSafeArea(.all)
        )

    }

}


struct PlaylistDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PlaylistDetailsView(playlist: MockPlaylist).edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/ .all/*@END_MENU_TOKEN@*/)
        }
    }
}
