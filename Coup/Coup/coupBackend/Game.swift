class Game{

  var all: [Player]
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
      move.
    }
  }
  func incrementInd(ind: inout Int){
    ind += 1
    if ind >= all.count{
      ind = 0
    }
  }
}
