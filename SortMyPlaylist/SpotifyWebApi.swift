//
//  SpotifyWebApi.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 11/07/2020.
//

import Combine
import Foundation

struct SpotifyAuthResponse: Codable {
    let accessToken: String
    let expiresIn: Int
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
    }
    
}

class SpotifyWebApi: ObservableObject {
    let baseUrl = "https://api.spotify.com/v1/"
    let spotifyClient = SpotifyAuthService.shared
    static let shared = SpotifyWebApi()

    var token: String {
        get {
            return spotifyClient.accessToken
        }
        set {}
    }

    func getAccessToken(autenticationCode: String) -> AnyPublisher<SpotifyAuthResponse, Error> {
        


        let url = URL(string: "https://accounts.spotify.com/api/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let requestHeader = ["Content-Type": "application/x-www-form-urlencoded"]
        request.allHTTPHeaderFields = requestHeader

        let body: [String : String] = [
            "code": autenticationCode,
            "grant_type": "authorization_code",
            "redirect_uri": "sortmyplaylist://spotify-login-callback",
            "client_id": SpotifyClient.SpotifyClientID,
            "client_secret": SpotifyClient.SpotifyClientSecret
        ]
        let jsonString = body.reduce("") { "\($0)\($1.0)=\($1.1)&" }.dropLast()
        let jsonData = jsonString.data(using: .utf8, allowLossyConversion: false)!
        request.httpBody = jsonData

        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data  }
            .decode(type: SpotifyAuthResponse.self, decoder: JSONDecoder())
            .handleEvents(receiveOutput:  { response  in
                DispatchQueue.main.async {
                    self.spotifyClient.accessToken = response.accessToken
                    self.spotifyClient.expirationDate = Date() + TimeInterval(response.expiresIn)
                    print(self.spotifyClient.accessToken)
                }
                
            })
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func getUser() -> AnyPublisher<Spotify.User, Error> {
        let request = httpRequest(url: "me", type: .Get)
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: Spotify.User.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func getPlaylists(_ url: String = "me/playlists?limit=50") -> AnyPublisher<[Spotify.Playlist], Error> {
        let request = httpRequest(url: url, type: .Get)
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
//                if let httpResponse = output.response as? HTTPURLResponse {
//                    if([400, 401].contains(httpResponse.statusCode)) {
//                        #warning("accessToken= shouldn't be set here")
//                        SpotifyAuthService.shared.accessToken = ""
//                        SpotifyAuthService.shared.setToken("")
//                    }
//                    print("statusCode: \(httpResponse.statusCode)")
//                }
                output.data
            }
            .decode(type: Spotify.PlaylistsResponse.self, decoder: JSONDecoder())
            .map { $0.items }
//            .flatMap({response -> AnyPublisher<[Spotify.PlaylistsResponse], Error> in
//                if response.next != nil {
//                    return self.getPlaylists().prepend(response)
//                } else {
//                   return Future<[Spotify.PlaylistsResponse], Error> { promise in
//                    promise(.success([response]))
//                    }.eraseToAnyPublisher()
//
//                }
//            })
//            .scan([], {$0 + $1})
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func getPlaylistTracks(playlist: Spotify.Playlist) -> AnyPublisher<[Spotify.Track], Error> {
        let maxNumberOfTracks = 100
        let requestCount = playlist.tracks.total / maxNumberOfTracks
        let offsets = (0 ..< requestCount + 1).map { $0 * maxNumberOfTracks }

        let endpoints = offsets.map { "playlists/" + playlist.id + "/tracks?offset=\($0)" }
        let requests = endpoints.map { httpRequest(url: $0, type: .Get) }
        return Publishers.MergeMany(requests.map({
            URLSession.shared.dataTaskPublisher(for: $0)
                .map {
                    $0.data
                }
                .decode(type: Spotify.PlaylistItems.self, decoder: JSONDecoder())
                .map { $0.items }
                .map { $0.compactMap { $0.track } }

                .flatMap { [self] tracks -> AnyPublisher<[Spotify.Track], Error> in
                    getTrackAndFeatures(tracks: tracks)
                }
        }
        ))
            .collect()
            .map { $0.flatMap { $0 } }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func getTrackAndFeatures(tracks: [Spotify.Track]) -> AnyPublisher<[Spotify.Track], Error> {
        let ids = tracks.map { $0.id }.joined(separator: ",")
        let request = httpRequest(url: "audio-features?ids=" + ids, type: .Get)
        var trackDictionary = [String: Spotify.Track]()
        tracks.forEach { track in trackDictionary[track.id] = track }
        let task = URLSession.shared.dataTaskPublisher(for: request)
        return
            task
                .map { $0.data }
                .decode(type: Spotify.AudioFeaturesResponse.self, decoder: JSONDecoder())
                .map { data in
                    data.audioFeatures.forEach { audioFeature in
                        trackDictionary[audioFeature.id]?.audioFeature = audioFeature
                    }
                    return tracks.map { $0.id }.map { id in trackDictionary[id] }.compactMap { $0 }
                }
                .eraseToAnyPublisher()
    }

    func playlistTrackReorder(playlistId: String, body: PutTrackBody) -> AnyPublisher<Bool, Error> {
        var req = httpRequest(url: "playlists/\(playlistId)/tracks", type: .Put)
        req.httpBody = try? JSONEncoder().encode(body)
        return URLSession.shared.dataTaskPublisher(for: req)
            .tryMap { output in
                if let httpResponse = output.response as? HTTPURLResponse {
                    print("statusCode: \(httpResponse.statusCode)")
                }
                return true
            }
            .eraseToAnyPublisher()
    }

    func updatePlaylistTrackOrders(playlistId: String, tracks: [EnumeratedSequence<[Spotify.Track]>.Element]) -> AnyPublisher<[Bool], Error> {
        var items = [Int](0 ..< tracks.count)
        let reqs: [PutTrackBody] = tracks.enumerated().map { idx, item in
            let currentIndex = items.firstIndex(of: item.offset)
            if currentIndex == idx {
                return nil
            }
            items.remove(at: currentIndex!)
            items.insert(item.offset, at: idx)
            return PutTrackBody(rangeStart: currentIndex!, rangeLength: 1, insertBefore: idx)
        }.compactMap { $0 }

        let requests = reqs.map { playlistTrackReorder(playlistId: playlistId, body: $0) }

        return requests.publisher
            .delay(for: .milliseconds(100), scheduler: RunLoop.main)
            .flatMap(maxPublishers: .max(1)) { request in request }
            .collect()
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

extension SpotifyWebApi {
    func httpRequest(baseUrl: String = "https://api.spotify.com/v1/", url: String, type: HttpRequestType) -> URLRequest {
        let url = URL(string: baseUrl + url)!
        var request = URLRequest(url: url)
        request.httpMethod = type.rawValue
        let token = self.token
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        return request
    }
}

struct PutTrackBody: Codable {
    let rangeStart, rangeLength, insertBefore: Int

    enum CodingKeys: String, CodingKey {
        case rangeStart = "range_start"
        case rangeLength = "range_length"
        case insertBefore = "insert_before"
    }
}

enum HttpRequestType: String {
    case Get = "GET"
    case Post = "POST"
    case Put = "PUT"
}
