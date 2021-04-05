//
//  SortCardListFormView.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 01/08/2020.
//

import SwiftUI

struct SortCardListFormView: View {
    @Binding var sortBy: SortPlaylist
    @State var sortingTracks = false
    @State var cancellable: Any?
    @State var showSuccessMessage = false
    @State var confirmMessage = false
    @State var animate = false
    let onUpdate: () -> ()
    let onCancel: () -> ()
    
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
                    Alert(title: Text("Playlist"),
                          message: Text("Successfully sorted by \(sortBy.by.rawValue)"),
                          dismissButton: .default(Text("Ok"), action: removeSelection))
                }

            }
        }

        .animation(.spring())
        .transition(
            .asymmetric(insertion: .move(edge: .trailing), removal: .identity)
        ).onReceive(AppStore.shared.actions) { action in
            if action is AppStore.PlaylistTracks.Action.LoadPlaylistTracksSuccess {
                showSuccessMessage = true
                sortingTracks = false
            }
        }
    }

    func removeSelection() {
        sortBy = .empty
    }

    func updatePlaylist() {
        sortingTracks = true
        onUpdate()
    }
    
    func cancelReordering() {
        sortingTracks = false
        removeSelection()
        onCancel()
    }
}

//struct SortCardListFormView_Previews: PreviewProvider {
//    static var previews: some View {
//        SortCardListFormView().environmentObject(PlaylistModel())
//    }
//}
