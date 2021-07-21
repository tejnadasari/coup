//turn ind is global, so we know when buttons should be hidden or not
class Game{
    var players: [Player]
    //all will be initailized by view controller
    var deck = Deck()
    
    init(all: [Player]){
        players = all //copy this
    }
    
    func runGame(){
        var gameOver = false
        var turnInd = 0
        
        while !gameOver{
            var curMove = players[turnInd].getMove()
            //AI will autogenerate a move based on game details
            //real player will start a while loop, that will not close until a boolean value holds false
            //boolean value will be set to false in an onClick method,
            //that will be shared between the player class and the view controller
            if let challenge = anyChallenges(){ //anyChallenges() returns a Move object, works similar to getMove
                if players[turnInd].haveCard(){ //will pass in cardRequired, member of Move class
                    challenge.callerPlayer.revealCard()
                }
                else{
                    challenge.targetPlayer.revealCard() //reveal card must present modally
                }
            }
            else{
                actOnMove(curMove) //switch case, updates game
            }
            if gameIsOver(){
                break
            }
            incrementInd(ind: &turnInd)
        }
    }
    
    func actOnMove(move: Move){
        switch move.moveName {
        case "income":
            move.callerPlayer.coins += 1
        case "foreignAid":
            move.callerPlayer.coins += 1
        case "coup":
            move.callerPlayer.coins -= 7
            move.targetPlayer.revealCard()
        case "drawNewRoles": //ambassador has option to exchange these cards
            //so we must modally present a view controller, displaying the two cards
            players[turnInd].choose() //how can we go to a new view controller
            /*deck.takeCard(move.callerPlayer.card1) //giving a card to a deck
            move.callerPlayer.takeCard(deck.giveACard())
            */
        case "assassinate":
            move.targetPlayer.revealCard()
        case "steal":
            move.targetPlayer.coins -= 2
            move.callerPlayer.coins += 2
        case "tax":
            move.callerPlayer.coins += 3
        default:
            break
        }
    }
    
    func incrementInd(ind: inout Int){
      ind += 1
      if ind >= all.count{
        ind = 0
      }
    }
    
    
}


