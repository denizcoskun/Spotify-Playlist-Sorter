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
    
    var authHeader: [String: String] {
        return ["Authorization": "Bearer " + self.token]
    }

    func getAccessToken(autenticationCode: String) -> AnyPublisher<SpotifyAuthResponse, Error> {

        let url = "https://accounts.spotify.com/api/token"
        let header = ["Content-Type": "application/x-www-form-urlencoded"]
        let body: [String : String] = [
            "code": autenticationCode,
            "grant_type": "authorization_code",
            "redirect_uri": "sortmyplaylist://spotify-login-callback",
            "client_id": SpotifyClient.SpotifyClientID,
            "client_secret": SpotifyClient.SpotifyClientSecret
        ]
        let jsonString = body.reduce("") { "\($0)\($1.0)=\($1.1)&" }.dropLast()
        let jsonData = jsonString.data(using: .utf8, allowLossyConversion: false)!
        
        return HttpClient.shared.post(SpotifyAuthResponse.self, url: url, data: jsonData, headers: header)
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
        return HttpClient.shared.get(Spotify.User.self, url: baseUrl + "me", headers: authHeader)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func getPlaylists(_ url: String = "me/playlists?limit=50") -> AnyPublisher<[Spotify.Playlist], Error> {
        
        return HttpClient.shared.get(Spotify.PlaylistsResponse.self,
                                  url: (baseUrl + url),
                                  headers:authHeader)
            .map { $0.items }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func getPlaylistTracks(playlist: Spotify.Playlist) -> AnyPublisher<[Spotify.Track], Error> {
        let maxNumberOfTracks = 100
        let requestCount = playlist.tracks.total / maxNumberOfTracks
        let offsets = (0 ..< requestCount + 1).map { $0 * maxNumberOfTracks }
        let endpoints: [String] = offsets.map { baseUrl + "playlists/" + playlist.id + "/tracks?offset=\($0)" }
        print(endpoints)
        return Publishers
            .MergeMany(endpoints.map({
                HttpClient.shared.get(Spotify.PlaylistItems.self, url: $0, headers: authHeader)
                    .map { $0.items }
                    .map { $0.compactMap { $0.track } }
                    .flatMap { [self] tracks -> AnyPublisher<[Spotify.Track], Error> in
                        getTrackAndFeatures(tracks: tracks)
                    }
            }))
            .collect()
            .map { $0.flatMap { $0 } }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func getTrackAndFeatures(tracks: [Spotify.Track]) -> AnyPublisher<[Spotify.Track], Error> {
        let ids = tracks.map { $0.id }.joined(separator: ",")
        let url = baseUrl + "audio-features?ids=" + ids
        var trackDictionary = [String: Spotify.Track]()
        tracks.forEach { track in trackDictionary[track.id] = track }
        return
            HttpClient.shared.get(Spotify.AudioFeaturesResponse.self, url: url, headers: authHeader)
                .map { data in
                    data.audioFeatures.forEach { audioFeature in
                        trackDictionary[audioFeature.id]?.audioFeature = audioFeature
                    }
                    return tracks.map { $0.id }.map { id in trackDictionary[id] }.compactMap { $0 }
                }
                .eraseToAnyPublisher()
    }

    func playlistTrackReorder(playlistId: String, body: PutTrackBody) -> AnyPublisher<Bool, Error> {
        let url = baseUrl + "playlists/\(playlistId)/tracks"
        let data = try? JSONEncoder().encode(body)
        return HttpClient.shared.put(url: url, data: data, headers: authHeader)
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



struct PutTrackBody: Codable {
    let rangeStart, rangeLength, insertBefore: Int

    enum CodingKeys: String, CodingKey {
        case rangeStart = "range_start"
        case rangeLength = "range_length"
        case insertBefore = "insert_before"
    }
}

