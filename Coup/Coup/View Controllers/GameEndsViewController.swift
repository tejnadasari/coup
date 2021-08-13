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
        DispatchQueue.main.async {
            Sound.stopPlay()
        }
        sleep(1)
        
        returnButton.isHidden = true
        statusLabel.text = ""
        
        mainMenuOption.layer.cornerRadius = 15
        mainMenuOption.layer.borderWidth = 2
        mainMenuOption.layer.borderColor = UIColor.black.cgColor
        
        if SettingsViewController.isLightModeEnabled() {
            overrideUserInterfaceStyle = .light
            self.view.backgroundColor = UIColor(hex: "#FFF8E1FF")
        } else {
            overrideUserInterfaceStyle = .dark
            self.view.backgroundColor = UIColor(hex: "#283747FF")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        typeStatus()
        spinStatus()
        returnButton.isHidden = false
        
        if SettingsViewController.isLightModeEnabled() {
            overrideUserInterfaceStyle = .light
            self.view.backgroundColor = UIColor(hex: "#FFF8E1FF")
        } else {
            overrideUserInterfaceStyle = .dark
            self.view.backgroundColor = UIColor(hex: "#283747FF")
        }
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
        self.performSegue(withIdentifier: "unwindToMainVC", sender: self)
    }
}
