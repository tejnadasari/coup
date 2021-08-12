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
    @IBOutlet weak var explainLabel: UILabel!
    
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

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        cardImage1.image = twoCards!.0.photo
        cardImage2.image = twoCards!.1.photo
        
        explainLabel.numberOfLines = 2
        explainLabel.text = "Press the card for which\nyou want to exchange \(userCard!.name!) for a few seconds"
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
