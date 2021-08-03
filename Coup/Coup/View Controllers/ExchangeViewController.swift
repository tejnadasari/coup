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
    
    // need to fetch two cards from GameViewController
    var twoCards: (Card, Card)?
    
    // need to fetch the card which will be exchanged to the card
    // chosen by user in this ViewController from GameViewController
    var userCard: Card?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cardImage1.image = twoCards!.0.photo
        cardImage2.image = twoCards!.1.photo
        
        explainLabel.numberOfLines = 2
        explainLabel.text = "Press the card for which\nyou want to exchange \(userCard!.name!) for a few seconds"

    }
    
    @IBAction func recognizeLongPressedGesture1 (recognizer: UILongPressGestureRecognizer){
        exchangeCards(userCard: &(self.userCard!), chosenCard: &(self.twoCards!.0))
    }
    
    @IBAction func recognizeLongPressedGesture2 (recognizer: UILongPressGestureRecognizer){
        exchangeCards(userCard: &(self.userCard!), chosenCard: &(self.twoCards!.1))
    }
    
    @IBAction func keepCardButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func exchangeCards(userCard:inout Card, chosenCard:inout Card) {
        var temp = Card()
    
        temp = userCard
        userCard = chosenCard
        chosenCard = temp
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
