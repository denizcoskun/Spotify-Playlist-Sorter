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
    
    let spotifyWebApi = SpotifyWebApi.shared

    lazy var sortedTracks: AnyPublisher<[EnumeratedSequence<[Spotify.Track]>.Element], Never> = {
        $tracks.map { $0.enumerated() }.combineLatest($sortPlaylist).map { tracks, sort in
            sort.by.sort(tracks: tracks, order: sort.order)
        }
        .assertNoFailure()
        .eraseToAnyPublisher()
    }()

    func rearrangeTracks(playlist: Spotify.Playlist, tracks: [EnumeratedSequence<[Spotify.Track]>.Element]) -> AnyPublisher<[Spotify.Track], Error> {
        return Just(tracks)
            .flatMap { [self] sortedTracks in
                spotifyWebApi.updatePlaylistTrackOrders(playlistId: playlist.id, tracks: sortedTracks)
            }
            .flatMap { _ in
                self.spotifyWebApi.getPlaylistTracks(playlist: playlist)
            }.eraseToAnyPublisher()
    }
}
