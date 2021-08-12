//
//  HowToPlayViewController.swift
//  Coup
//
//  Created by Sungwook Kim on 2021/07/30.
//

import UIKit

class HowToPlayViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var howToPlayLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        howToPlayLabel.text! = "How to Play?"
               
        descriptionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 1800))
        descriptionLabel.numberOfLines = 750
        descriptionLabel.font = UIFont(name: "Avenir", size: 16)
        descriptionLabel.text = """
            Game Objectives:
            
            1. At the start of the game, each player is given 2 roles (cards) which are confidential from the other players & $2
            2. The goal is for each player to reveal the others' cards through several actions (some involve the money).
            3. When both the cards of a player are revealed, they are kicked out of the game.
            
            
            Winner: The last player who has one or more unrevealed cards wins.

            Game Roles(cards) & Actions:
            Note: At the end of each player's turn: everyone else can challenge or allow the move.
            
            1. Ambassador
                Exclusive Action: Exchange - Takes 2 cards and returns two cards
            2. Assassin
                Exclusive Action: Assassinate - Pays 3 coins to reveal an influence
            3. Captain
                Exclusive Action: Steal - Takes 2 coins from another player
            4. Contessa
                Exclusive Action: Foreign Aid - Takes 2 coins from the treasury
            5. Duke
                Exclusive Action: Tax - Takes 3 coins from the treasury
            
            Everyone
            1. Generic Action: Anyone can draw $1 of income
            2. Foreign Aid: Anyone can draw $2 of foreign aid
            3. Coup: Once 7 coins are collected, a player can force another to show one of their cards.
            
            Turn Actions:
            1. Allow: When another player takes can action they can approve it
            2. Challenge: When another player suspects that someone is bluffing about their cards, they can force the other people to reveal their card.
                a. If the challenger's notion is correct, then the action will not be carried out, they are forced to discard the card which will then be shuffled into the deck and they will recieve a new card.
                b. If the challenger's notion is incorrect, then their action will be carried out as normal.
            
            Additional Information
            1. There are a total of 15 cards, consisting of 3 each of the roles.
            2. Treasury: Pool of money that is distributed between throughout the players and game.
            3. Strategy: Bluff so your correct characters are never revealed.
            """
        scrollView.addSubview(descriptionLabel)
        scrollView.contentSize = descriptionLabel.bounds.size
        scrollView.contentOffset = CGPoint(x: 0, y: 60)
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 3.0
        scrollView.zoomScale = 1.0
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return descriptionLabel
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
