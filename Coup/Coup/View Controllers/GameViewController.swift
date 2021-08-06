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
 
 
 IMPORTANT FOR TABLEVIEW:
 The user should be able to highlight a user, and then click a button.
 A user should not be able to click a button, without having a user highlighted (for moves that require a target).
 Once a user is highlighted, we need to be able to get their name, so we can properly create a Move object.
 */

import UIKit

class GameViewController: UIViewController/*, UITableViewDelegate, UITableViewDataSource*/  {
    /*func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var test: UITableViewCell =
        return test
    }*/
    
    
    @IBOutlet weak var coupBtn: UIButton!
    @IBOutlet weak var taxBtn: UIButton!
    @IBOutlet weak var stealBtn: UIButton!
    @IBOutlet weak var assassinateBtn: UIButton!
    @IBOutlet weak var allowBtn: UIButton!
    @IBOutlet weak var incomeBtn: UIButton!
    @IBOutlet weak var exchangeBtn: UIButton!
    @IBOutlet weak var challengeBtn: UIButton!
    @IBOutlet weak var foreignBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var deck: Deck?
    var numPlayers: Int? //this will be set in a prepare function in the previous VC
    var players: [Player] = [] //this is set in previous VC
    
    var playerMove: Move = Move() //this is the move the player chooses
    var didPlayerMove: Bool = false //did the player select a move yet
    var turnInd: Int = 0 //current turn
    var didPlayerChallengeOrAllow = false
    var challengeTurnInd: Int = 0 //whose turn it is to select challenge or allow
    var challengeMove: Move = Move() //this is the move that is chosen for challenge/allow
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deck = Deck()
        //runGame(resume: false, playerMove: Move())
        players.append(Player()) //real player
    }
    
    func runGame(resume: Bool, playerMove: Move){
        
        var gameOn:Bool = true
        while gameOn{
            var curMove: Move = Move()
            let currentPlayer = players[turnInd]
            if (currentPlayer.name == "real" && didPlayerMove == false){
                enableButtons()
                break
            }
            else if (currentPlayer.name == "real"){
                curMove = playerMove
                didPlayerMove = false
            }
            else{
                curMove = currentPlayer.getPlayerMove()
            }
            //curMove is now set
            //checking for challenges
            let objection = anyChallenges(move: curMove) //move
            if (objection.name == "challenge"){
                if currentPlayer.checkhaveCard(cardName: curMove.name){ //will pass in cardRequired, member of Move class
                    objection.caller.revealCard()
                }
                else{
                    objection.target.revealCard() //reveal card must present modally
                }
            }
            if (objection.name == "allow"){
                actOnMove(move: curMove)
            }
            incrementInd(ind: &turnInd)
        }
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
        case "drawNewRoles": break //ambassador has option to exchange these cards
            //so we must modally present a view controller, displaying the two cards
            //how can we go to a new view controller
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
    
    func enableButtons(){
        coupBtn.isEnabled = true
        taxBtn.isEnabled = true
        stealBtn.isEnabled = true
        assassinateBtn.isEnabled = true
        foreignBtn.isEnabled = true
        incomeBtn.isEnabled = true
        exchangeBtn.isEnabled = true
        challengeBtn.isEnabled = false
        allowBtn.isEnabled = false
    }
    
    func enableChallengeButtons(){
        coupBtn.isEnabled = false
        taxBtn.isEnabled = false
        stealBtn.isEnabled = false
        assassinateBtn.isEnabled = false
        foreignBtn.isEnabled = false
        incomeBtn.isEnabled = false
        exchangeBtn.isEnabled = false
        challengeBtn.isEnabled = true
        allowBtn.isEnabled = true
    }
    
    func anyChallenges(move: Move) -> Move{
        var curMove: Move = Move()
        while challengeTurnInd < players.count{
            let player = players[challengeTurnInd]
            if (player.name == "real"){
                enableChallengeButtons()
                break
            }
            else{
                curMove = player.getPlayerMove()
            }
            if (didPlayerChallengeOrAllow){
                curMove = challengeMove
            }
            if (curMove.name == "challenge"){
                return curMove
            }
        }
        return curMove
    }
    
    func incrementInd(ind: inout Int) {
      ind += 1
      if ind >= players.count{
        ind = 0
      }
    }
        
    @IBAction func coupBtnPressed(_ sender: Any) { //how do we select target
    }
    @IBAction func taxBtnPressed(_ sender: Any) {
    }
    @IBAction func stealBtnPressed(_ sender: Any) {
    }
    @IBAction func assassinateBtnPressed(_ sender: Any) {
    }
    @IBAction func allowBtnPressed(_ sender: Any) {
        didPlayerChallengeOrAllow = true
        challengeMove = Move(name: "allow", caller: players[challengeTurnInd], target: players[turnInd])
    }
    @IBAction func incomeBtnPressed(_ sender: Any) {
    }
    @IBAction func foreignBtnPressed(_ sender: Any) {
    }
    @IBAction func exchangeBtnPressed(_ sender: Any) {
    }
    @IBAction func challengeBtnPressed(_ sender: Any) {
        didPlayerChallengeOrAllow = true
        challengeMove = Move(name: "challenge", caller: players[challengeTurnInd], target: players[turnInd])
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
