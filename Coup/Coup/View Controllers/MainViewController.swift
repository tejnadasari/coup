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
        GameViewController.playNextLevel()
    }

    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
    }
}
