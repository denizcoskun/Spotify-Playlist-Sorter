//
//  TrackListView.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 12/07/2020.
//

import SwiftUI

struct TrackListView: View {
    let tracks: [Spotify.Track]

    let playlistName: String
    @State var sortPlaylist = SortPlaylist(by: .none, order: .none)

    var sortedTracks: [EnumeratedSequence<[Spotify.Track]>.Element] {
        return sortPlaylist.by.sort(tracks: tracks.enumerated(), order: sortPlaylist.order)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack {
                    ForEach(0 ..< sortedTracks.count, id: \.self) { id in
                        TrackListItemView(
                            id: id, track: sortedTracks[id],
                            showArrows: sortPlaylist.by != .none
                        ).padding(.all, 10)
                    }
                }
                .navigationBarTitle(playlistName, displayMode: .automatic)
            }
            .clipped()
            .frame(maxWidth: .infinity)
            SortCardListView(sortPlaylist: $sortPlaylist)

        }
    }
}

struct TrackListItemView: View {
    var id: Int
    var track: EnumeratedSequence<[Spotify.Track]>.Element
    var showArrows: Bool = false
    @ObservedObject var previewPlayer = TrackPreviewPlayer.shared
    var body: some View {
        VStack {
            EmptyView()
            HStack(alignment: VerticalAlignment.lastTextBaseline) {
                Group { if showArrows {
                    Image(systemName: track.offset > id ? "arrow.up" : track.offset < id ? "arrow.down" : "arrow.left.and.right")

                } else {
                    Text("\(id + 1).").frame(width: 40)
                }
                }.font(.caption)
                    .frame(width: 20)
                Text("\(track.element.name)").font(.subheadline).padding(.top, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/).padding(.bottom, 0)
                Text("- \(track.element.artists?.first?.name ?? "N/A")").font(.subheadline).italic()
                Spacer()
                if let previewUrl = track.element.previewUrl {
                    playerButton(previewUrl: previewUrl)
                }
            }.lineLimit(1)
        }
        .foregroundColor(.white).frame(maxWidth: .infinity)
    }

    var isPlaying: Bool {
        previewPlayer.trackId == track.element.id && previewPlayer.status == .playing
    }

    func togglePlayer(previewUrl: String) {
        if isPlaying {
            previewPlayer.stopPlayer()
        } else {
            previewPlayer.playTrackPreview(trackId: track.element.id, string: previewUrl)
        }
    }

    func playerButton(previewUrl: String) -> some View {
        Button(action: {
            print(track.element.previewUrl ?? "")
            togglePlayer(previewUrl: previewUrl)
        }) {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .foregroundColor(.white)
                .padding(10)
                .background(
                    Group {
                        if isPlaying {
                            ZStack {
                                Circle()
                                    .stroke(Color.white, lineWidth: 2.0)
                                Circle()
                                    .trim(from: 0, to: CGFloat(previewPlayer.progress))
                                    .rotation(.degrees(-90))
                                    .stroke(Color.Spotify.green, lineWidth: 2.0)
                                    .animation(.linear(duration: 0.1))
                            }
                        } else {
                            EmptyView()
                        }
                    }
                )

        }.padding(.trailing, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
        
    }
}

//
struct TrackListItemView_Previews: PreviewProvider {
    static var previews: some View {
        TrackListView(tracks: [], playlistName: "").background(Color.black)
            .edgesIgnoringSafeArea(.all)
    }
}
