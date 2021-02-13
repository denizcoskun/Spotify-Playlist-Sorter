//
//  SpotifyPlaylist.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 12/07/2020.
//

import Foundation
import Hue

enum Spotify {
    struct User: Codable {
        let id: String
        let displayName: String
        enum CodingKeys: String, CodingKey {
            case id
            case displayName = "display_name"
        }
    }

    struct PlaylistsResponse: Codable {
        let href: String
        let items: [Spotify.Playlist]
        let limit: Int
        let offset: Int
        let total: Int
        var next: String? = nil
    }

    struct Playlist: Codable, Identifiable, Equatable {
        static func == (lhs: Spotify.Playlist, rhs: Spotify.Playlist) -> Bool {
            ((try? JSONEncoder().encode(lhs) == JSONEncoder().encode(rhs)) != nil)
        }
        
        let id: String
        let href: String
        let images: [Spotify.Image]?
        let name: String
        let tracks: Spotify.Tracks
        let uri: String
        let collaborative: Bool
        let owner: Spotify.User
        enum CodingKeys: String, CodingKey {
            case id, href, images, name, tracks, uri, collaborative, owner
        }
    }

    struct Image: Codable {
        let height: Int?
        let width: Int?
        let url: String
    }

    struct Tracks: Codable {
        let href: String
        let total: Int
    }

    struct PlaylistItems: Codable {
        @LossyArray var items: [Spotify.PlaylistItem]
    }

    struct PlaylistItem: Codable {
        let track: Spotify.Track?
        enum CodingKeys: String, CodingKey {
            case track
        }
    }

    struct Track: Codable, Equatable {
        static func == (lhs: Spotify.Track, rhs: Spotify.Track) -> Bool {
            lhs.id == rhs.id
        }
        
        let id: String
        let artists: [Artist]?
        let album: Spotify.Album?
        let href: String?
        let name: String
        let popularity: Int
        let previewUrl: String?
        var audioFeature: Spotify.AudioFeature?
        var audioFeatures: Spotify.AudioFeature {
            get {
                audioFeature ?? AudioFeature(id: id, danceability: 0, energy: 0, key: 0, loudness: 0, mode: 0, speechiness: 0, acousticness: 0, instrumentalness: 0, liveness: 0, valence: 0, tempo: 0, durationMS: 0, timeSignature: 0)
            } set {}
        }

        enum CodingKeys: String, CodingKey {
            case id, name, artists, album, href, popularity, audioFeature
            case previewUrl = "preview_url"
        }

        enum Sortables {
            static let popularity = \Track.popularity
            static let beats = \Track.audioFeatures.tempo
            static let energy = \Track.audioFeatures.energy
            static let acousticness = \Track.audioFeatures.acousticness
            static let instrumentalness = \Track.audioFeatures.instrumentalness
            static let liveness = \Track.audioFeatures.liveness
            static let duration = \Track.audioFeatures.durationMS
            static let danceability = \Track.audioFeatures.danceability
            static let loudness = \Track.audioFeatures.loudness
            static let positivity = \Track.audioFeatures.valence
            static let speechiness = \Track.audioFeatures.speechiness
        }
    }

    struct Artist: Codable {
        let id, name, type, uri, href: String?

        enum CodingKeys: String, CodingKey {
            case href, id, name, type, uri
        }
    }

    struct Album: Codable {
        let id: String?
        let href: String?
        let images: [Image]?
        let name, releaseDate: String?

        enum CodingKeys: String, CodingKey {
            case href, id, images, name
            case releaseDate = "release_date"
        }
    }

    struct AudioFeature: Codable {
        let id: String
        let danceability, energy: CGFloat
        let key: Int
        let loudness: CGFloat
        let mode: Int
        let speechiness, acousticness, instrumentalness, liveness: CGFloat
        let valence, tempo: CGFloat
        let durationMS, timeSignature: Int
        enum CodingKeys: String, CodingKey {
            case danceability, energy, key, loudness, mode, speechiness, acousticness, instrumentalness, liveness, valence, tempo, id
            case durationMS = "duration_ms"
            case timeSignature = "time_signature"
        }
    }

    struct AudioFeaturesResponse: Codable {
        let audioFeatures: [AudioFeature]
        enum CodingKeys: String, CodingKey {
            case audioFeatures = "audio_features"
        }
    }

    enum SortOrder: String {
        case asc, dec, none

        func compareFn<T: Comparable>() -> (T, T) -> Bool {
            switch self {
            case .asc:
                return (<)
            case .dec:
                return (>)
            case .none:
                return (>)
            }
        }

        var iconName: String {
            switch self {
            case .asc:
                return "arrowtriangle.up.fill"
            case .dec:
                return "arrowtriangle.down.fill"
            case .none:
                return ""
            }
        }

        mutating func toggle() {
            if self == .none {
                self = .none
                return
            }
            self = self == .asc ? .dec : .asc
        }
    }

    enum SortAttribute: String, CaseIterable {
        //        Beats Per Minute (BPM) - The tempo of the song.
        //        Energy - The energy of a song - the higher the value, the more energtic. song
        //        Danceability - The higher the value, the easier it is to dance to this song.
        //        Loudness - The higher the value, the louder the song.
        //        Valence - The higher the value, the more positive mood for the song.
        //        Length - The duration of the song.
        //        Acoustic - The higher the value the more acoustic the song is.
        //        Popularity - The higher the value the more popular the song is.
        //        Lucky - A randon number. Sort by this column to shuffle your playlist.
        case beats, energy, danceability, loudness, positivity, length, acoustic, popularity, none

        func sort(tracks: EnumeratedSequence<[Spotify.Track]>, order: SortOrder) -> [EnumeratedSequence<[Spotify.Track]>.Element] {
            switch self {
            case .acoustic:
                return tracks.sorted(keyPath: Spotify.Track.Sortables.acousticness, comparator: order.compareFn())
            case .beats:
                return tracks.sorted(keyPath: Spotify.Track.Sortables.beats, comparator: order.compareFn())
            case .danceability:
                return tracks.sorted(keyPath: Spotify.Track.Sortables.danceability, comparator: order.compareFn())
            case .energy:
                return tracks.sorted(keyPath: Spotify.Track.Sortables.energy, comparator: order.compareFn())
            case .length:
                return tracks.sorted(keyPath: Spotify.Track.Sortables.duration, comparator: order.compareFn())
            case .loudness:
                return tracks.sorted(keyPath: Spotify.Track.Sortables.duration, comparator: order.compareFn())
            case .positivity:
                return tracks.sorted(keyPath: Spotify.Track.Sortables.positivity, comparator: order.compareFn())
            case .popularity:
                return tracks.sorted(keyPath: Spotify.Track.Sortables.popularity, comparator: order.compareFn())
//            case .lucky:
//                return tracks.shuffled()
            case .none:
                return tracks.sorted(by: { $0.offset < $1.offset })
            }
        }

        var colour: UIColor {
            switch self {
            case .beats:
                return UIColor(hex: "FFBE0B")
            case .danceability:
                return UIColor(hex: "FB5607")
            case .energy:
                return UIColor(hex: "FF006E")
            case .loudness:
                return UIColor(hex: "8338EC")
            case .positivity:
                return UIColor(hex: "3A86FF")
            case .acoustic:
                return UIColor(hex: "FEE440")
            case .popularity:
                return UIColor(hex: "00F5D4")
            default:
                return UIColor(hex: "9B5DE5")
            }
        }
    }
}

let mockAudioFeature = Spotify.AudioFeature(id: "", danceability: 0, energy: 0, key: 0, loudness: 0, mode: 0, speechiness: 0, acousticness: 0, instrumentalness: 0, liveness: 0, valence: 0, tempo: 0, durationMS: 0, timeSignature: 0)
let MockArtist = Spotify.Artist(id: "", name: "arts", type: "Artist", uri: "", href: "")
let MockImage = Spotify.Image(height: 640, width: 640, url: "https://i.scdn.co/image/ab67616d0000b273c68098bb3bb73febde6aae89")
let MockAlbum = Spotify.Album(id: "", href: "", images: [MockImage], name: "Mock Album", releaseDate: "")
let MockTrack = Spotify.Track(id: "1234", artists: [MockArtist], album: MockAlbum, href: "", name: "Mock Track", popularity: 10, previewUrl: "https://p.scdn.co/mp3-preview/87b539823b0aa1023ef29c5592bdd94b21826957?cid=774b29d4f13844c495f206cafdad9c86", audioFeature: mockAudioFeature)
let MockPlaylistItem = Spotify.PlaylistItem(track: MockTrack)
let MockPlaylistItems = Spotify.PlaylistItems(items: [MockPlaylistItem])
let MockTracks = Spotify.Tracks(href: "", total: 120)
let MockUser = Spotify.User(id: "12", displayName: "mock user")
let MockPlaylist = Spotify.Playlist(id: "mock-id", href: "", images: [MockImage], name: "Mock Playlist", tracks: MockTracks, uri: "", collaborative: false, owner: MockUser)
let MockPlaylistResponse = Spotify.PlaylistsResponse(href: "", items: Array(repeating: MockPlaylist, count: 20), limit: 10, offset: 10, total: 0, next: nil)

// http://marksands.github.io/2019/10/21/better-codable-through-property-wrappers.html
// Property wrappers require this annotation at the top level of the type
@propertyWrapper
public struct LossyArray<T: Codable>: Codable {
    // we previously saw the AnyDecodableValue technique
    private struct AnyDecodableValue: Codable {}

    // LossyDecodableValue is a single value of a generic type that we attempt to decode
    private struct LossyDecodableValue<Value: Codable>: Codable {
        let value: Value

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            value = try container.decode(Value.self)
        }
    }

    // every property wrapper requires a wrappedValue
    public var wrappedValue: [T]

    public init(wrappedValue: [T]) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        var elements: [T] = []

        // continue decoding until we get to the last element
        while !container.isAtEnd {
            do {
                // try to decode an arbitrary value of our generic type T
                let value = try container.decode(LossyDecodableValue<T>.self).value
                elements.append(value)
            } catch {
                // if that fails, no sweat—we still need to move our decoding cursor past that element
                _ = try? container.decode(AnyDecodableValue.self)
            }
        }

        // and finally we store our elements
        wrappedValue = elements
    }

    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

extension Spotify {
    struct RefreshTokenResponse: Codable {
        let accessToken, refreshToken: String
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case refreshToken = "refresh_token"
        }
    }
}
