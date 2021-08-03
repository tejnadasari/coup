/*
 
 - At the start of their turn, a player performs one of several actions. Some actions can always be played, while others require a specific role:
 
 1. getIncome - Draw $1 of income
 2. getForeignAid - Draw $2 of foreign aid (duke can block)
 3. stageCoup - Pay $7 to stage a coup -> forcing a player of your choice to
               reveal one influence (cannot be blocked)
 4 .tax(duke) - The duke can claim tax, gaining $3
 5. assassinate(assassin) - The assassin can pay $3 to make a player of their choice
                 reveal an influence (if the targeted player has the contessa,
                 they can block the assassination)
 6. exchange2Roles(ambassador) - The ambassador can draw two new roles and choose to
              exchange any of them with their remaining hidden influences
 7. steal(captain) - The captain can steal $2 from another player (if the
           targeted player has the ambassador or the captain, they can block)
 8. block
 9. challenge

 Assassin
 Ambassador
 Captain
 Contessa
 Duke

 -> After playing an action, the other players have an opportunity to block the action or to challenge it. After this the turn passes to the next player.
 
 
 */
import UIKit

class Card{
    var name: String?
    var photo: UIImage?
    var tax: Bool?
    var assassinate: Bool?
    var exchange2Roles: Bool?
    var steal: Bool?
}

class Assassin: Card {
    
    override init() {
        super.init()
        name = "Assassin"
        photo = UIImage(named: "Assassin.jpeg")
        tax = false
        assassinate = true
        exchange2Roles = false
        steal = false
    }
    
}

class Ambassador: Card {
    
    override init() {
        super.init()
        name = "Ambassador"
        photo = UIImage(named: "Ambassador.jpeg")
        tax = false
        assassinate = true
        exchange2Roles = false
        steal = false
    }
    
}

class Captain: Card {
    
    override init() {
        super.init()
        name = "Captain"
        photo = UIImage(named: "Captain.jpeg")
        tax = false
        assassinate = true
        exchange2Roles = false
        steal = false
    }
    
}

class Contessa: Card {
    
    override init() {
        super.init()
        name = "Contessa"
        photo = UIImage(named: "Contessa.jpeg")
        tax = false
        assassinate = true
        exchange2Roles = false
        steal = false
    }
    
}

class Duke: Card {
    
    override init() {
        super.init()
        name = "Duke"
        photo = UIImage(named: "Duke.jpeg")
        tax = false
        assassinate = true
        exchange2Roles = false
        steal = false
    }
    
}
