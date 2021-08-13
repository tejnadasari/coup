//
//  BlankViewController.swift
//  Coup
//
//  Created by Xinyi Zhu on 8/8/21.
//

import UIKit

class BlankViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SettingsViewController.isLightModeEnabled() {
            overrideUserInterfaceStyle = .light
            self.view.backgroundColor = UIColor(hex: "#FFF8E1FF")
        } else {
            overrideUserInterfaceStyle = .dark
            self.view.backgroundColor = UIColor(hex: "#283747FF")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if SettingsViewController.isLightModeEnabled() {
            overrideUserInterfaceStyle = .light
            self.view.backgroundColor = UIColor(hex: "#FFF8E1FF")
        } else {
            overrideUserInterfaceStyle = .dark
            self.view.backgroundColor = UIColor(hex: "#283747FF")
        }
    }
}
