//
//  PlaylistListView.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 11/07/2020.
//

import SwiftUI

struct PlaylistListView: View {
    let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200)),
    ]
    @State var playlists: [Spotify.Playlist] = []
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                self.list()
            }.padding(/*@START_MENU_TOKEN@*/ .all/*@END_MENU_TOKEN@*/, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
        }
        .navigationBarHidden(false)
        .navigationBarTitle("Your Playlists", displayMode: .automatic)
        .navigationBarBackButtonHidden(true)
        .frame(maxHeight: .infinity)
        .background(Rectangle()
            .fill(LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.App.winterSky, location: 0),
                    .init(color: Color.Spotify.black, location: 0.76),
                    .init(color: Color.Spotify.black, location: 1),
                ]),
                startPoint: UnitPoint(x: -0.67, y: -0.68),
                endPoint: UnitPoint(x: 1, y: 1)
            )).edgesIgnoringSafeArea(.all))
        .onReceive(AppStore.shared.playlistsState) {playlists in
            self.playlists = playlists
            print(playlists.count)
        }
    }

    func list() -> some View {
        return Group {
            if playlists.count > 0 {
                ForEach(playlists, id: \.self.id) { playlist in
                    NavigationLink(
                        destination: PlaylistDetailsView(playlist: playlist).navigationBarBackButtonHidden(true)
                            .edgesIgnoringSafeArea(.bottom)

                    ) {
                        self.card(playlist: playlist)
                    }
                }
            } else {
                EmptyView()
            }
        }
    }

    func card(playlist: Spotify.Playlist) -> some View {
        Group {
            VStack {
                RemoteImageView(url: playlist.images?.first?.url)
                    .frame(minHeight: 90)
                Text("\(playlist.name)").foregroundColor(.white).lineLimit(1)
            }
            .padding(.all, 20)
            .frame(maxWidth: .infinity, maxHeight: 220)
            .background(
                RoundedRectangle(cornerRadius: 10).foregroundColor(Color.Spotify.darkGrey).shadow(radius: 10))
        }
    }
}

struct PlaylistListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Group {
                PlaylistListView().background(Color.Spotify.black)

                PlaylistListView().edgesIgnoringSafeArea(.all
                ).background(Color.Spotify.black)
                    .previewLayout(PreviewLayout.fixed(width: 800, height: 320))
            }
        }
    }
}
