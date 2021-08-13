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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if SettingsViewController.isSoundEnabled() && audioPlayer == nil {
            Sound.playMainSong()
        }
    }

    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
    }
}
