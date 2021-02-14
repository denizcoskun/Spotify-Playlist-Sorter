//
//  SortCardListFormView.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 01/08/2020.
//

import SwiftUI

struct SortCardListFormView: View {
    @EnvironmentObject var playlistModel: PlaylistModel
    @State var sortingTracks = false
    @State var cancellable: Any?
    @State var showSuccessMessage = false
    @State var confirmMessage = false
    @State var animate = false
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Button(action: { confirmMessage = true }) {
                    HStack {
                        if sortingTracks {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                                .padding(2)

                        } else {
                            Image(systemName: "icloud.and.arrow.up")
                        }

                        Text(sortingTracks ? "Saving" : "Save   ").font(.title3)
                        
                    }
                }
                .disabled(sortingTracks)
                .padding(EdgeInsets(top: 15, leading: 30, bottom: 15, trailing: 30))
                .foregroundColor(.white)
                .background(Capsule().foregroundColor(sortingTracks ? Color.Spotify.darkGrey : Color.Spotify.green).shadow(radius: 10))
                .padding(.trailing, 10)
                .alert(isPresented: $confirmMessage) {
                    Alert(title: Text("Warning"),
                          message: Text("This action will change the order of the tracks and it is irreversable. \n Do you want to continue?"),
                          primaryButton: .default(Text("Ok")) { updatePlaylist() },
                          secondaryButton: .cancel { removeSelection() })
                }

                Button(action: cancelReordering) {
                    Text("Cancel")
                        .padding(EdgeInsets(top: 15, leading: 30, bottom: 15, trailing: 30))
                        .foregroundColor(.white)
                }
                .animation(Animation.spring().delay(0.2))
                .padding(.trailing, 10)
                .alert(isPresented: $showSuccessMessage) {
                    Alert(title: Text("\(playlistModel.playlist!.name)"),
                          message: Text("Successfully sorted by \(playlistModel.sortPlaylist.by.rawValue)"),
                          dismissButton: .default(Text("Ok"), action: removeSelection))
                }
            }
        }
        .animation(.spring())
        .transition(
            .asymmetric(insertion: .move(edge: .trailing), removal: .identity)
        ).onReceive(AppStore.shared.actions) { action in
            if case PlaylistTracksStore.Action.LoadPlaylistTracksSuccess(_, _) = action {
                playlistModel.sortPlaylist = .empty
                sortingTracks = false
            }
        }
    }

    func removeSelection() {
        playlistModel.sortPlaylist = .empty
    }

    func updatePlaylist() {
        sortingTracks = true
        cancellable = playlistModel.sortedTracks.first().map { tracks in
            AppStore.shared.dispatch(action: PlaylistTracksStore.Action.ReorderPlaylistTracks(playlistModel.playlist!, tracks))
        }.sink(receiveCompletion: { _ in }, receiveValue: { _ in
        })
    }
    
    func cancelReordering() {
        sortingTracks = false
        removeSelection()
        AppStore.shared.dispatch(action: PlaylistTracksStore.Action.CancelReorderPlaylistTracks)
    }
}

struct SortCardListFormView_Previews: PreviewProvider {
    static var previews: some View {
        SortCardListFormView().environmentObject(PlaylistModel())
    }
}
