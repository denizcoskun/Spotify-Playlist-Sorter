//
//  TrackPreviewPlayer.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 25/07/2020.
//

import AVFoundation
import Combine
import Foundation

class TrackPreviewPlayer: ObservableObject {
    static let shared = TrackPreviewPlayer()
    @Published var status = AVPlayer.TimeControlStatus.paused
    var playerItem: AVPlayerItem?
    var player: AVPlayer?
    var subscription: AnyCancellable?
    @Published var trackId: String = ""
    @Published var currentTime: Double = 0
    var songDuration: Double = 30

    @Published var progress: Double = 0
    var timeObserverToken: Any?
    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        } catch {
            print(error)
        }
    }

    func stopPlayer() {
        trackId = ""
        currentTime = 0
        player?.pause()
    }

    func playTrackPreview(trackId: String, string: String) {
        self.trackId = trackId
        guard let url = URL(string: string) else {
            return
        }
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        subscription =
            player?.publisher(for: \.timeControlStatus, options: [.initial])
                .map {
                    print($0.rawValue)
                    return $0
                }
                .sink(receiveValue: { self.status = $0 })
        addPeriodicTimeObserver()
        player?.play()
    }

    func addPeriodicTimeObserver() {
        // Invoke callback every half second
        let interval = CMTime(seconds: 0.1,
                              preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        // Add time observer. Invoke closure on the main queue.
        timeObserverToken =
            player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) {
                [weak self] _ in
                self?.currentTime = self?.player?.currentTime().seconds ?? 0
                if let currentTime = self?.currentTime, let songDuration = self?.songDuration {
                    self?.progress = songDuration > 0 ? currentTime / songDuration : 0
                }
            }
    }
}
