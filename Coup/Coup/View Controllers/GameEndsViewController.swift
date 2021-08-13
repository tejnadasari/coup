//
//  CheatSheetViewController.swift
//  Coup
//
//  Created by Xinyi Zhu on 7/3/21.
//

import UIKit
import AVFoundation

class GameEndsViewController: UIViewController {
    
    static var status = "undefined"
    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var mainMenuOption: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        returnButton.isHidden = true
        statusLabel.text = ""
        
        mainMenuOption.layer.cornerRadius = 15
        mainMenuOption.layer.borderWidth = 2
        mainMenuOption.layer.borderColor = UIColor.black.cgColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        typeStatus()
        MainViewController.playMainSong()
        spinStatus()
        returnButton.isHidden = false
    }
    
    func typeStatus() {
        for char in GameEndsViewController.status {
            if SettingsViewController.isSoundEnabled() {
                AudioServicesPlaySystemSound(1306)
            }
            
            statusLabel.text! += "\(char)"
            RunLoop.current.run(until: Date() + 0.12)
        }
    }
    
    func spinStatus() {
        let durationValue = 3.0
        
        UIView.animate(
            withDuration: durationValue,
            delay: 0.0,
            options: [.repeat, .autoreverse],
            animations: {
                // 180 degree rotation
                self.statusLabel.transform =
                    self.statusLabel.transform.rotated(by: CGFloat(Double.pi))
                }
        )
    }
    
    @IBAction func playAgainPressed(_ sender: Any) {
        statusLabel.layer.removeAllAnimations()
        if SettingsViewController.isSoundEnabled() && !MainViewController.audioPlayer!.isPlaying {
            MainViewController.playMainSong()
        }
        self.performSegue(withIdentifier: "unwindToMainVC", sender: self)
    }
}
