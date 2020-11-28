//
//  SortCardListFormView.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 01/08/2020.
//

import SwiftUI

struct SortCardListFormView: View {
    @EnvironmentObject var playlistModel: PlaylistModel
    @EnvironmentObject var appStore: AppStore
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Button(action: updatePlaylist) {
                    HStack {
                        if appStore.rearrangingTrack {
                            Text("Saving").font(.title3)
                        } else {
                            Image(systemName: "icloud.and.arrow.up")
                            Text("Save").font(.title3)
                        }
                    }.animation(.none)
                }
                .disabled(appStore.rearrangingTrack)
                .padding(EdgeInsets(top: 15, leading: 30, bottom: 15, trailing: 30))
                .foregroundColor(.white)
                .background(Capsule().foregroundColor(Color.Spotify.green).shadow(radius: 10))
                .padding(.trailing, 10)

                Button(action: removeSelection) {
                    Text("Cancel")
                        .padding(EdgeInsets(top: 15, leading: 30, bottom: 15, trailing: 30))
                        .foregroundColor(.white)
                }
                .animation(Animation.spring().delay(0.2))
                .padding(.trailing, 10)
            }
        }
        .animation(.spring())
        .transition(
            .asymmetric(insertion: .move(edge: .trailing), removal: .identity)
        ).onReceive(playlistModel.playlistUpdated) { _ in
            self.appStore.loadPlaylistTracks(playlist: playlistModel.playlist!)
        }
    }

    func removeSelection() {
        playlistModel.sortPlaylist = .empty
    }

    func updatePlaylist() {
        _ = playlistModel.sortedTracks.first().sink(receiveValue: { tracks in
            self.appStore.rearrangeTracks(playlist: playlistModel.playlist!, tracks: tracks)
        })
    }
}

struct SortCardListFormView_Previews: PreviewProvider {
    static var previews: some View {
        SortCardListFormView().environmentObject(PlaylistModel())
    }
}
