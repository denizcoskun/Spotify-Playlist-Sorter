//
//  SortCardListView.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 01/08/2020.
//

import Combine
import SwiftUI
struct SortCardListView: View {
    @EnvironmentObject var playlistModel: PlaylistModel
    @State var faceUpAttribute: Spotify.SortAttribute? = nil

    var body: some View {
        ZStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Spacer()
                    ForEach(attributes, id: \.self) { sortAttribute in
                        SortCardView(
                            attribute: sortAttribute,
                            sortPlaylist: self.$playlistModel.sortPlaylist,
                            faceUpAttribute: $faceUpAttribute
                        )
                        .transition(.move(edge: .bottom))
                        .animation(.easeOut)
                        .frame(minWidth: 120)
                        .frame(height: 120)

                        .padding(EdgeInsets(top: 10, leading: 5, bottom: max(UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0, 10), trailing: 5))
                    }
                    Spacer()
                }
            }.frame(maxWidth: .infinity)

            if playlistModel.sortPlaylist.by != .none {
                SortCardListFormView()
            }
        }

        .background(
            Group {
                if playlistModel.sortPlaylist.by != .none {
                    Rectangle().fill(Color(0x343A40)).transition(.opacity)
                } else {
                    EmptyView()
                }
            }
        )
        .animation(.default)
    }

    func isSelected(_ attribute: Spotify.SortAttribute) -> Bool {
        playlistModel.sortPlaylist.by == attribute
    }

    var attributes: [Spotify.SortAttribute] {
        if playlistModel.sortPlaylist.by != .none {
            return [playlistModel.sortPlaylist.by]
        }
        return [.beats, .energy, .danceability, .loudness, .positivity, .length, .acoustic, .popularity]
    }

    func removeSelection() {
        playlistModel.sortPlaylist = .empty
    }
}

struct SortCardListView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            SortCardListView().environmentObject(PlaylistModel())
        }
        .previewDevice(PreviewDevice(rawValue: "iPhone XS Max"))

        .background(Color(0x212529))
        .edgesIgnoringSafeArea(.all)
    }
}
