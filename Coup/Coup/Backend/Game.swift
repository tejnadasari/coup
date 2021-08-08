//turn ind is global, so we know when buttons should be hidden or not
import UIKit

class Game{
    var players: [Player]
    //all will be initailized by view controller
    var deck = Deck()
    var turnInd = 0
    
    init(all: [Player]){
        players = all //copy this
    }
    
    func runGame(){
        var gameOver = false
    
        while !gameOver {
            var curMove = players[turnInd].getPlayerMove()
            //AI will autogenerate a move based on game details
            //real player will start a while loop, that will not close until a boolean value holds false
            //boolean value will be set to false in an onClick method,
            //that will be shared between the player class and the view controller
            if let challenge = anyChallenges(){ //anyChallenges() returns a Move object, works similar to getMove
                if players[turnInd].checkhaveCard(cardName: curMove.name){ //will pass in cardRequired, member of Move class
                    challenge.caller.revealCard()
                }
                else{
                    challenge.target.revealCard() //reveal card must present modally
                }
            }
            else{
                actOnMove(move: curMove) //switch case, updates game
            }
            if gameOver {
                break
            }
            incrementInd(ind: &turnInd)
        }
    }
    
    func anyChallenges() -> Move? {
        return Move(name: "", caller: Player(name: "", photo: UIImage(named: "Ariana Grande.jpg")!, cards: (Card(), Card())), target: Player(name: "", photo: UIImage(named: "Ariana Grande.jpg")!, cards: (Card(), Card())))
    }
    
    func actOnMove(move: Move){
        switch move.name {
        case "income":
            move.caller.coins += 1
        case "foreignAid":
            move.caller.coins += 1
        case "coup":
            move.caller.coins -= 7
            move.target.revealCard()
        case "exchange": //ambassador has option to exchange these cards
            //so we must modally present a view controller, displaying the two cards
            players[turnInd].choose() //how can we go to a new view controller
            /*deck.takeCard(move.callerPlayer.card1) //giving a card to a deck
            move.callerPlayer.takeCard(deck.giveACard())
            */
        case "assassinate":
            move.target.revealCard()
        case "steal":
            move.target.coins -= 2
            move.caller.coins += 2
        case "tax":
            move.caller.coins += 3
        default:
            break
        }
    }
    
    func incrementInd(ind: inout Int) {
      ind += 1
      if ind >= players.count{
        ind = 0
      }
    }
}
