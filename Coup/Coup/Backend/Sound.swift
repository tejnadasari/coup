//
//  Sound.swift
//  Coup
//
//  Created by Xinyi Zhu on 8/12/21.
//

import Foundation
import AVFoundation

var audioPlayerMainSong: AVAudioPlayer?
var audioPlayerSound: AVAudioPlayer?

class Sound {
    
    // MARK: - Sound Effects
    
    static func playIncome() {
        Sound.playSound(file: "Cash Register")
    }
    
    static func playChallenge() {
        Sound.playSound(file: "Challenge")
    }
    
    static func playGame() {
        Sound.playSound(file: "Waiting")
    }
    
    static func playKill() {
        Sound.playSound(file: "Kill")
    }
    
    static func playAllow() {
        Sound.playSound(file: "Allow")
    }
    
    static func playLose() {
        Sound.playSound(file: "Lose")
    }
    
    static func playExchange() {
        Sound.playSound(file: "Exchange")
    }
    
    // MARK: - Main Song
    
    static func playMainSong() {
        Sound.playMainSong(file: "Piano")
    }
    
    // MARK: - General
    
    static func stopPlay() {
        audioPlayerMainSong?.stop()
        audioPlayerMainSong = nil
    }
    
    static func pausePlay() {
        audioPlayerMainSong?.pause()
    }
    
    static func continuePlay() {
        audioPlayerMainSong?.play()
    }
    
    static func playMainSong(file: String) {
        if !SettingsViewController.isSoundEnabled() {
            return
        }

        guard let url = Bundle.main.url(forResource: file, withExtension: "m4a") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayerMainSong = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)
            guard let audioPlayer = audioPlayerMainSong else { return }
            audioPlayer.numberOfLoops = -1
            audioPlayer.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    static func playSound(file: String) {
        if !SettingsViewController.isSoundEnabled() {
            return
        }

        guard let url = Bundle.main.url(forResource: file, withExtension: "m4a") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayerSound = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)
            guard let audioPlayer = audioPlayerSound else { return }
            audioPlayer.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
