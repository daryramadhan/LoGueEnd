//
//  backgroundMusic.swift
//  LoGueEnd
//
//  Created by Dary Ramadhan on 26/05/23.
//

import AVFoundation

class BackgroundMusicManager {
    static let shared = BackgroundMusicManager()
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    
    private init() {
        // Private initializer to enforce singleton pattern
    }
    
    func playBackgroundMusic() {
        if let musicURL = Bundle.main.url(forResource: "background-music-audio", withExtension: "m4a") {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: musicURL)
                backgroundMusicPlayer?.numberOfLoops = -1  // Infinite loop
                backgroundMusicPlayer?.prepareToPlay()
                backgroundMusicPlayer?.play()
            } catch {
                print("Failed to play background music: \(error.localizedDescription)")
            }
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
    }
}

