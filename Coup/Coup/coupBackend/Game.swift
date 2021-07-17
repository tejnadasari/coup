//game needs to be a view controller, to hide different components
class Game{

  var all: [Player]
    
    Deck = new Deck
    deck.givemeacard()
    deck.giveCard(card)
    
  func turn(){

    var turnInd = 0
    var gameOver = false

    while !gameOver{
      curMove = getPlayerMove()

      if let challenge = anyChallenges(){
        if all[turnInd].haveCard(){
          challenge.callerPlayer.revealCard()
        }
        else{
          challenge.targetPlayer.revealCard()
        }
      }
      else{
        actOnMove(curMove)
      }
      if gameIsOver(){
        break
      }
    }
  }

  func actOnMove(move: Move){
    switch move.moveName{
    case "income":
      move.callerPlayer.coins += 1
    }
    case "foreignAid":
      move.callerPlayer.coins += 1
    }
    case "coup":
      move.callerPlayer.coins -= 7
      move.targetPlayer.revealCard()
    default:
      break
  }

  func incrementInd(ind: inout Int){
    ind += 1
    if ind >= all.count{
      ind = 0
    }
  }
}

