//
//  ExchangeViewController.swift
//  Coup
//
//  Created by Sungwook Kim on 2021/08/03.
//

import UIKit

class ExchangeViewController: UIViewController {

    @IBOutlet weak var cardImage1: UIImageView!
    @IBOutlet weak var cardImage2: UIImageView!
    @IBOutlet weak var cardLabel1: UILabel!
    @IBOutlet weak var cardLabel2: UILabel!
    @IBOutlet weak var explainLabel: UILabel!
    @IBOutlet weak var keepCardsLabel: UIButton!
    
    // delegate for applying any changes
    var delegate: UIViewController?
    
    // need to fetch two cards from GameViewController
    var twoCards: (Card, Card)?
    
    // need to fetch the card which will be exchanged to the card
    // chosen by user in this ViewController from GameViewController
    var userCard: Card?
    var caseNum: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardImage1.isUserInteractionEnabled = true
        cardImage2.isUserInteractionEnabled = true
        
        let longPressRecognizer1 = UILongPressGestureRecognizer(target: self, action: #selector(recognizeLongPressedGesture1(recognizer:)))
        self.cardImage1.addGestureRecognizer(longPressRecognizer1)
        
        let longPressReconizer2 = UILongPressGestureRecognizer(target: self, action: #selector(recognizeLongPressedGesture2(recognizer:)))
        self.cardImage2.addGestureRecognizer(longPressReconizer2)
        
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
        
        cardImage1.image = twoCards!.0.photo
        cardImage2.image = twoCards!.1.photo
        cardLabel1.text = twoCards!.0.name
        cardLabel2.text = twoCards!.1.name
        
        explainLabel.numberOfLines = 2
        explainLabel.text = "Hold down on the card you want\n in exchange for your \(userCard!.name!)"
    }
    
    @IBAction func recognizeLongPressedGesture1 (recognizer: UILongPressGestureRecognizer){
        let gameVC = self.delegate as? ApplyExchangeDelegate
        let gameVC2 = self.delegate as? SwitchbuttonDelegate
        
        if caseNum == 0 {
            gameVC?.applyExchange(chosenCard: twoCards!.0, caseNum: 0)
        } else if caseNum == 2 {
            gameVC?.applyExchange(chosenCard: twoCards!.0, caseNum: 2)
        } else {
            print("Not Applicable")
        }
        
        gameVC2?.switchButton()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func recognizeLongPressedGesture2 (recognizer: UILongPressGestureRecognizer){
        let gameVC = self.delegate as? ApplyExchangeDelegate
        let gameVC2 = self.delegate as? SwitchbuttonDelegate
        
        if caseNum == 0 {
            gameVC?.applyExchange(chosenCard: twoCards!.1, caseNum: 1)
        } else if caseNum == 2 {
            gameVC?.applyExchange(chosenCard: twoCards!.1, caseNum: 3)
        } else {
            print("Not Applicable")
        }
        
        gameVC2?.switchButton()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func keepCardButtonPressed(_ sender: Any) {
        let gameVC2 = self.delegate as? SwitchbuttonDelegate
        gameVC2?.switchButton()
        dismiss(animated: true, completion: nil)
    }
}
