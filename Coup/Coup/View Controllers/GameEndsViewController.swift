//
//  CheatSheetViewController.swift
//  Coup
//
//  Created by Xinyi Zhu on 7/3/21.
//

import UIKit
import AVFoundation

class GameEndsViewController: UIViewController {
    
    var status = "undefined"

    @IBOutlet weak var statusLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        typeStatus()
        spinStatus()
    }
    
    func typeStatus() {
        for char in status {
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
            delay: 1.0,
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
