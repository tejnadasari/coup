/*
 How will gameplay work:
 
 Previous view controller will initialize: numberOfAI
 
 Deck, and AI array will be initialized. Entire array will just be AI.
 User will be included within the array
 
 ViewDidLoad will call runGame(false) method, will also be in this file
 
 RunGame() will consist of a while loop (moving the Game backend to this file)
    1)Go through array
    2)GetplayerMove() return boolean
        When it is the actual player, always return a move with movename = "real"
            if movename == "real" then break out of loop
                button onClick listeners call runGame(true), now we have input from user
                runGame(true) skips to the line after getPlayerMove()
        When it is the AI, some calculation is done and move is returned
    3)anyChallenges(false), returns a move as well
        loop that just goes through entire player array
        asks getChallengeOrAllow(), AI does calculation, real player return movename = "real"
            if movename == "real" then break out of while loop
                button onClick listeners will now call anyChallenges(true), now we have input from user
                anyChallenges(true) skips to line directly after getChallengeOrAllow()
            if move is a challenge, then stop and return that move
            else return an empty move, indicating there is no challenge
    4)then the game updates the game stats based on the move made and whether there was a challenge or not
    5)checks to see if game over, if game is not over then loop continues
    6) if game is over, then break out of it, and make sure nothing else happens
 */

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var coupBtn: UIButton!
    @IBOutlet weak var taxBtn: UIButton!
    @IBOutlet weak var stealBtn: UIButton!
    @IBOutlet weak var assassinateBtn: UIButton!
    @IBOutlet weak var allowBtn: UIButton!
    @IBOutlet weak var incomeBtn: UIButton!
    @IBOutlet weak var exchangeBtn: UIButton!
    @IBOutlet weak var challengeBtn: UIButton!
    @IBOutlet weak var foreignBtn: UIButton!
    
    var deck: Deck?
    var numPlayers: Int? //this will be set in a prepare function in the previous VC
    var players: [Player] = [] //this is set in previosu VC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deck = Deck()
        runGame(resume: false)
        players.append(Player()) //real player
    }
    
    func runGame(resume: Bool){
        
        var gameOn:Bool = true
        var turnInd: Int = 0
        while gameOn{
            
            if (!resume){
                let currentPlayer = players[turnInd]
                let curMove = currentPlayer.getPlayerMove()
                if (curMove.name == "real"){
                    enableButtons()
                    break //to wait for button click from user
                }
                else{
                    let objection = anyChallenges() //move
                    if (objection.name == "real"){ //wait for user input
                        break
                    }
                    if (objection.name == "challenge"){
                        if currentPlayer.checkhaveCard(cardName: curMove.name){ //will pass in cardRequired, member of Move class
                            objection.caller.revealCard()
                        }
                        else{
                            objection.target.revealCard() //reveal card must present modally
                        }
                    }
                    if (objection.name == "allow"){
                    }
                }
            }
            //player has just made a move at this point
        }
    }
    
    func enableButtons(){
        coupBtn.isEnabled = true
        taxBtn.isEnabled = true
        stealBtn.isEnabled = true
        assassinateBtn.isEnabled = true
        allowBtn.isEnabled = false
        incomeBtn.isEnabled = true
        exchangeBtn.isEnabled = true
        challengeBtn.isEnabled = false
        foreignBtn.isEnabled = true
    }
    
    func anyChallenges() -> Move{
        return Move()
    }
    
    func incrementInd(ind: inout Int) {
      ind += 1
      if ind >= players.count{
        ind = 0
      }
    }
        
    @IBAction func coupBtnPressed(_ sender: Any) {
    }
    @IBAction func taxBtnPressed(_ sender: Any) {
    }
    @IBAction func stealBtnPressed(_ sender: Any) {
    }
    @IBAction func assassinateBtnPressed(_ sender: Any) {
    }
    @IBAction func allowBtnPressed(_ sender: Any) {
    }
    @IBAction func incomeBtnPressed(_ sender: Any) {
    }
    @IBAction func foreignBtnPressed(_ sender: Any) {
    }
    @IBAction func exchangeBtnPressed(_ sender: Any) {
    }
    @IBAction func challengeBtnPressed(_ sender: Any) {
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
