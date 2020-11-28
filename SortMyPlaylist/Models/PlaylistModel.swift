//
//  PlaylistModel.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 26/07/2020.
//

import Combine
import Foundation

struct SortPlaylist {
    let by: Spotify.SortAttribute
    var order: Spotify.SortOrder
    static let empty = SortPlaylist(by: .none, order: .none)
}

class PlaylistModel: ObservableObject {
    @Published var playlist: Spotify.Playlist?
    @Published var sortPlaylist = SortPlaylist(by: .none, order: .none)
    @Published var tracks: [Spotify.Track] = []
    @Published var updating = false
    var playlistUpdated = PassthroughSubject<Bool, Never>()
    let spotifyWebApi = SpotifyWebApi.shared
    var cancellable: AnyCancellable?

    lazy var sortedTracks: AnyPublisher<[EnumeratedSequence<[Spotify.Track]>.Element], Never> = {
        $tracks.map { $0.enumerated() }.combineLatest($sortPlaylist).map { tracks, sort in
            sort.by.sort(tracks: tracks, order: sort.order)
        }
        .assertNoFailure()
        .eraseToAnyPublisher()
    }()

    func updatePlaylist() {
        updating = true
        print("updating")
        cancellable = sortedTracks
            .first()
            .flatMap { [self] sortedTracks in
                spotifyWebApi.updatePlaylistTrackOrders(playlistId: self.playlist!.id, tracks: sortedTracks)
            }
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { [self] _ in
                updating = false
            }, receiveValue: { [self] _ in
                updating = false
                sortPlaylist = .empty
                self.playlistUpdated.send(true)
            })
    }
}
