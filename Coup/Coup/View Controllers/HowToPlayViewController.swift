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

        howToPlayLabel.text! = "How to Play?"
               
        descriptionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 1500))
        descriptionLabel.numberOfLines = 750
        descriptionLabel.font = UIFont(name: "Avenir", size: 16)
        descriptionLabel.text = """
            Game Objectives:
            
            1. At the start of the game, each player is given 2 roles (cards) which are confidential from the other players & $2
            2. The goal is for each player to reveal the others' cards through several actions (some involve money).
            3. When both the cards of a player are revealed, they are kicked out of the game.
            
            
            Winner: The last player who has one or more unrevealed card(s) wins.

            Game Roles (cards) & Actions:
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
            2. Coup: Once 7 coins are collected, a player can force another to show one of their cards.
            
            Turn Actions:
            1. Allow: When another player takes can action, you can choose to approve it.
            2. Challenge: When you suspect that someone is bluffing about their cards, you can force the other people to reveal their card.
                a. If you are correct, then the action will not be carried out. The other player will be forced to discard a card, which will then be shuffled into the deck and they will recieve a new card.
                b. If you are incorrect, then the other player's action will be carried out as normal.
            
            Additional Information
            1. There are a total of 15 cards, consisting 3 of each of the roles.
            2. Treasury: Pool of money that is distributed among the players and overall game.
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
}
