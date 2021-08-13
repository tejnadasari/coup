//
//  Sound.swift
//  Coup
//
//  Created by Xinyi Zhu on 8/12/21.
//

import Foundation
import AVFoundation

var audioPlayer: AVAudioPlayer?

class Sound {
    // MARK: - Sound Effects
    
    static func playIncome() {
        Sound.playSound(file: "Cash Register")
    }
    
    static func playChallenge() {
        Sound.playSound(file: "Count Down")
    }
    
    static func playGame() {
        Sound.playSound(file: "Waiting")
    }
    
    static func playMainSong() {
        Sound.playSound(file: "Next Level")
    }
    
    static func stopPlay() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    static func pausePlay() {
        audioPlayer?.pause()
    }
    
    static func continuePlay() {
        audioPlayer?.play()
    }
    
    static func playSound(file: String) {
        if !SettingsViewController.isSoundEnabled() {
            return
        }

        guard let url = Bundle.main.url(forResource: file, withExtension: "m4a") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)
            guard let audioPlayer = audioPlayer else { return }
            audioPlayer.numberOfLoops = -1
            audioPlayer.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
