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
               
        descriptionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 390, height: 2000))
        descriptionLabel.numberOfLines = 1000
        descriptionLabel.text = """
            1. The game begins giving two cards to each player. Each player gets two roles(cards) which are confidential from the other players.

            2. Each player can force each other to reveal one card through several actions.

            3. When both of two cards of a player are revealed, they are kicked out of the game.
            The last player who has one or more unrevealed  cards wins.

            4. There are five different roles(cards):
                - Ambassador
                - Assassin
                - Captain
                - Contessa
                - Duke
             -> Two cards from a pool of 15, consisting of 3 of each of the 5 roles, will be given to each player at the beginning of the game.

            5. $2 also will be given to each player and you will see how you use the money you get in the next section(6).

            6. Several Actions you can take:

             - At each player's turn, a player can take one of these diverse actions below (some actions can only be taken or only be blocked by a specific role):
             
            # Income - Anyone can draw $1 of income

            # Foreign Aid - Anyone can draw $2 of foreign aid -> (duke can block)

            # Coup - Anyone can pay $7 to stage a coup : forcing a player of your choice to show one of his or her cards -> (cannot be blocked)

            # Tax - Duke can claim tax, getting $3

            # Assassinate - Assassin can let a player of their choice to reveal one of the cards, paying $3 -> (If the chosen player owns Contessa, they can block Assassinate)

            # Exchange - Ambassador can draw 2 new roles and get the right of choice if they will exchange any of them with their current hidden cards

            # Steal - Captain may steal $2 from a player of their choice -> (If the chosen player owns Ambassador, they can block Steal)

            # Allow - When a player try to take an action, you will allow it with no doubt although the action can be taken by a specific role

            # Challenge - Unlikely to Allow, if you doubt a player has not the roles(cards) you claim, you can challenge them.
             -> The player must reveal the card that you claimed, if your doubt was right, the player's original action will be not carried out, and the player may no longer use the card. Otherwise, you must reveal your card as a penalty. And the card that the player revealed, will be shuffled back to the deck, and they will get a new card. After failed challenge, the player's original action will be taken as usual (Income, Foreign Aid, Coup which do not need specific role to be taken can never be challenged)

            # Block - You can decide to block a player's action with one of your cards(roles) If other players doubt you do not have the card(role), they can challenge you.

            7. Note: 2 ways in which you can lose both of cards at one go
               1) When you fail to challenge Assassination
                 -> you lose one card as a penalty of failing challenge, another by being assassinated.
               2) When you try to block Assassination lying that you have Contessa, but challenged
                 -> you lose one card by being challenged successfully by others, another by being assassinated.

            Sources from: https://coup.thebrown.net/rules.html
            """
        scrollView.addSubview(descriptionLabel)
        
        scrollView.backgroundColor = UIColor.white
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
