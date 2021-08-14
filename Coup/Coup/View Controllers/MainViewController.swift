//
//  ViewController.swift
//  Coup
//
//  Created by Xinyi Zhu on 7/3/21.
//

import UIKit

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if SettingsViewController.isSoundEnabled() {
            Sound.playMainSong()
        }
        setUpMode()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if SettingsViewController.isSoundEnabled() && audioPlayerMainSong == nil {
            Sound.playMainSong()
        }
        setUpMode()
    }
    
    func setUpMode() {
        if SettingsViewController.isLightModeEnabled() {
            overrideUserInterfaceStyle = .light
            self.view.backgroundColor = UIColor(hex: "#FFF8E1FF")
        } else {
            overrideUserInterfaceStyle = .dark
            self.view.backgroundColor = UIColor(hex: "#283747FF")
        }
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
    }
}
