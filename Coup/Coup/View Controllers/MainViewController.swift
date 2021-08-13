//
//  ViewController.swift
//  Coup
//
//  Created by Xinyi Zhu on 7/3/21.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {
    
    static var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        if SettingsViewController.isSoundEnabled() {
            MainViewController.playMainSong()
        }
    }

    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
    }
    
    // MARK: - Sound Effects
    
    static func playIncome() {
        MainViewController.playSound(file: "Cash Register")
    }
    
    static func playChallenge() {
        MainViewController.playSound(file: "Count Down")
    }
    
    static func playGame() {
        MainViewController.playSound(file: "Waiting")
    }
    
    static func playMainSong() {
        MainViewController.playSound(file: "Next Level")
    }
    
    static func stopPlay() {
        MainViewController.audioPlayer?.stop()
    }
    
    static func pausePlay() {
        MainViewController.audioPlayer?.pause()
    }
    
    static func continuePlay() {
        MainViewController.audioPlayer?.play()
    }
    
    static func playSound(file: String) {
        if !SettingsViewController.isSoundEnabled() {
            return
        }

        guard let url = Bundle.main.url(forResource: file, withExtension: "m4a") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            MainViewController.audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)
            guard let audioPlayer = MainViewController.audioPlayer else { return }
            audioPlayer.numberOfLoops = -1
            audioPlayer.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
