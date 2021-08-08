/*
 How will gameplay work:
 
 Previous view controller will initialize: numberOfAI / players
 
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

var players: [Player] = []

protocol ApplyExchangeDelegate {
    func applyExchange(chosenCard: Card, caseNum: Int)
}

class GameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ApplyExchangeDelegate {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userCoinLabel: UILabel!
    @IBOutlet weak var userCard1Label: UILabel!
    @IBOutlet weak var userCard2Label: UILabel!
    
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
    var highlightSwitch = false
    
    var deck: Deck? // deck for game
    var twoCards: (Card, Card)? // twoCards for exchange
    var userCard: Card? // userCard for exchange
    var caseNum: Int?
    
//    var numPlayers: Int? //this will be set in a prepare function in the previous VC
    //var players: [Player] = [] //this is set in previous VC
    var user: Player?
    var AIs: [Player] = []
    
    var playerMove: Move = Move() //this is the move the player chooses
    var didPlayerMove: Bool = false //did the player select a move yet
    var turnInd: Int = 0 //current turn
    var didPlayerChallengeOrAllow = false
    var challengeTurnInd: Int = 0 //whose turn it is to select challenge or allow
    var challengeMove: Move = Move() //this is the move that is chosen for challenge/allow
    var targetInd: Int = -1 //the index in the players array of whoever is being targeted
    
    var status = "You Lost"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make Deck and assign 2 cards to each player
        deck = Deck()
        deck!.assign2Cards(players: players)
        
        //runGame(resume: false, playerMove: Move())
//        players.append(Player()) //real player
        
        // for tableView
        tableView.delegate = self
        tableView.dataSource = self
        
        // make AIs
        AIs = players
        AIs.remove(at: 0)
        
        // for user
        user = players[0]
        userImageView.image = user!.photo
        userNameLabel.text = user!.name
        userCoinLabel.text = "$ \(user!.coins)"
        userCard1Label.text = "Card 1: \(user!.cards.0)"
        userCard2Label.text = "Card 2: \(user!.cards.1)"
    }
    
    // After assigning 2 cards to each player, 
    func runGame(){
        
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
                if currentPlayer.checkhaveCard(cardName: curMove.name){//fix up in player class
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
    
    //still need to update the labels!
    func revealCard(curPlayer: Player){
        if (curPlayer.name == "real"){}
        else{
            if (!curPlayer.cards.0.revealed){
                curPlayer.cards.0.revealed = true
            }
            else if (!curPlayer.cards.1.revealed){
                curPlayer.cards.1.revealed = true
            }
            else{
                //both of their cards are already revealed
            }
        }
    }
    
    func actOnMove(move: Move){
        switch move.name {
        case "income":
            move.caller.coins += 1
        case "foreignAid":
            move.caller.coins += 2
        case "coup":
            move.caller.coins -= 7
            move.target.revealCard()
        case "exchange":
            // get 2 cards from the current deck
            twoCards = deck!.give2Cards()
            
            // if the caller's first card has not revealed yet,
            // give them a chance to exchange it for another one from twoCards
            if self.user!.cards.0.revealed == false {
                userCard = user!.cards.0
                caseNum = 0
                self.performSegue(withIdentifier: "exchangeSegueIdentifier", sender: nil)
            }
            
            // if the caller's second card has not revealed yet,
            // give them a chance to exchange it for another one from twoCards
            if self.user!.cards.1.revealed == false {
                userCard = user!.cards.1
                caseNum = 2
                self.performSegue(withIdentifier: "exchangeSegueIdentifier", sender: nil)
            }
            
            // give 2 cards back to the current deck -> shuffle activated
            deck!.get2CardsBackNShuffle(twoCards: twoCards!)
            
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
        challengeTurnInd = 0
        while challengeTurnInd < players.count{
            let player = players[challengeTurnInd]
            if (player.name == move.caller.name){
                continue
            }
            if (player.name == "real"){
                enableChallengeButtons()
                break
            }
            else{
                curMove = player.getChallengeOrAllow(target: move.caller)
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
        if (targetInd != -1){
            didPlayerMove = true
            playerMove = Move(name: "coup", caller: players[turnInd], target: players[targetInd])
        }
    }
    @IBAction func taxBtnPressed(_ sender: Any) {
        if (targetInd != -1){
            didPlayerMove = true
            playerMove = Move(name: "tax", caller: players[turnInd], target: players[targetInd])
        }
    }
    @IBAction func stealBtnPressed(_ sender: Any) {
        if (targetInd != -1){
            didPlayerMove = true
            playerMove = Move(name: "steal", caller: players[turnInd], target: players[targetInd])
        }
    }
    @IBAction func assassinateBtnPressed(_ sender: Any) {
        if (targetInd != -1){
            didPlayerMove = true
            playerMove = Move(name: "assassinate", caller: players[turnInd], target: players[targetInd])
        }
    }
    @IBAction func allowBtnPressed(_ sender: Any) {
        didPlayerChallengeOrAllow = true
        challengeMove = Move(name: "allow", caller: players[challengeTurnInd], target: players[turnInd])
    }
    @IBAction func incomeBtnPressed(_ sender: Any) {
        didPlayerMove = true
        playerMove = Move(name: "income", caller: players[turnInd], target: players[turnInd])
    }
    @IBAction func foreignBtnPressed(_ sender: Any) {
        didPlayerMove = true
        playerMove = Move(name: "foreignAid", caller: players[turnInd], target: players[targetInd])
    }
    @IBAction func exchangeBtnPressed(_ sender: Any) {
        didPlayerMove = true
        playerMove = Move(name: "exchange", caller: players[turnInd], target: players[targetInd])
        //intiate segue here
    }
    @IBAction func challengeBtnPressed(_ sender: Any) {
        didPlayerChallengeOrAllow = true
        challengeMove = Move(name: "challenge", caller: players[challengeTurnInd], target: players[turnInd])
    }
    
    // MARK:- ApplyExchangeDelegate for exchange2Roles
    
    func applyExchange(chosenCard: Card, caseNum: Int) {
        switch caseNum {
        
        case 0:
            twoCards!.0 = user!.cards.0
            user!.cards.0 = chosenCard
            
        case 1:
            twoCards!.1 = user!.cards.0
            user!.cards.0 = chosenCard
            
        case 2:
            twoCards!.0 = user!.cards.1
            user!.cards.1 = chosenCard
            
        case 3:
            twoCards!.1 = user!.cards.1
            user!.cards.1 = chosenCard
            
        default:
            print("Not Applicable")
        }
    }
    
    // MARK:- tableView function
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AIs.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // write the code you want to implement when the cell was selected
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return highlightSwitch
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameLogTableViewCell", for: indexPath) as! GameLogTableViewCell
        
        let row = indexPath.row
        
        // Configure the cell...
        cell.aiImageView.image = AIs[row].photo
        cell.aiNameLabel.text = AIs[row].name
        cell.moneyLabel.text = "$ \(AIs[row].coins)"
        cell.identity1Label.text = AIs[row].cards.0.name
        cell.identity2Label.text = AIs[row].cards.1.name

        return cell
    }
    

    // MARK: - Segues

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "activityLogSegueIdentifier",
           let activityLogVC = segue.destination as? ActivityLogViewController {
            activityLogVC.players = players
//            activityLogVC.activityLog = 
        }
        else if segue.identifier == "exchangeSegueIdentifier",
           let exchangeVC = segue.destination as? ExchangeViewController {
            exchangeVC.delegate = self
            exchangeVC.twoCards = twoCards
            exchangeVC.userCard = userCard
            exchangeVC.caseNum = caseNum
        }
        else if segue.identifier == "gameEndsSegueIdentifier",
           let nextVC = segue.destination as? GameEndsViewController {
            nextVC.status = status
        }
    }
}
