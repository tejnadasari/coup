/*
 How will gameplay work:
 
 Previous view controller will initialize: numberOfAI / players
 
 Deck, and AI array will be initialized. Entire array will just be AI.
 User will be included within the array
 
 ViewDidLoad will call runGame(false) method, will also be in this file
 
 RunGame() will consist of a while loop (moving the Game backend to this file)
    1)Go through array
    2)GetplayerMove() return boolean
        When it is the actual player, always return a move with movename = LoginViewController.getUsername()
            if movename == LoginViewController.getUsername() then break out of loop
                button onClick listeners call runGame(true), now we have input from user
                runGame(true) skips to the line after getPlayerMove()
        When it is the AI, some calculation is done and move is returned
    3)anyChallenges(false), returns a move as well
        loop that just goes through entire player array
        asks getChallengeOrAllow(), AI does calculation, real player return movename = LoginViewController.getUsername()
            if movename == LoginViewController.getUsername() then break out of while loop
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
var moveLog: [Move] = []

protocol ApplyExchangeDelegate {
    func applyExchange(chosenCard: Card, caseNum: Int)
}

class GameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ApplyExchangeDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userCoinLabel: UILabel!
    @IBOutlet weak var userCard1Label: UILabel!
    @IBOutlet weak var userCard2Label: UILabel!
    @IBOutlet weak var card1ImageView: UIImageView!
    @IBOutlet weak var card2ImageView: UIImageView!
    
    @IBOutlet weak var coupBtn: UIButton!
    @IBOutlet weak var taxBtn: UIButton!
    @IBOutlet weak var stealBtn: UIButton!
    @IBOutlet weak var assassinateBtn: UIButton!
    @IBOutlet weak var allowBtn: UIButton!
    @IBOutlet weak var incomeBtn: UIButton!
    @IBOutlet weak var exchangeBtn: UIButton!
    @IBOutlet weak var challengeBtn: UIButton!
    @IBOutlet weak var foreignBtn: UIButton!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var userStack: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Variables
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
    var userCellColor = UIColor.clear
    var AICellColors: [UIColor] = []
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        disableAllButtons()
        
        // make Deck and assign 2 cards to each player
        deck = Deck()
        deck!.assign2Cards(players: players)
        
        // for tableView
        tableView.delegate = self
        tableView.dataSource = self
        
        // setup AIs and user
        setupAIs()
        setupUser()

        runGame()
    }
    
    func setupAIs() {
        AIs = players
        AIs.remove(at: 0)
        addAIColors()
    }
    
    func setupUser() {
        user = players[0]
        userImageView.image = user!.photo
        userNameLabel.text = user!.name
        userCoinLabel.text = "$ \(user!.coins)"
        userCard1Label.text = user!.cards.0.name!
        card1ImageView.image = user!.cards.0.photo
        userCard2Label.text = user!.cards.1.name!
        card2ImageView.image = user!.cards.1.photo
    }
    
    // MARK: - Run game
    
    // After assigning 2 cards to each player, 
    func runGame(){
        
        var gameOn:Bool = true
        
        while gameOn{
            dismissHighlights()
            var curMove: Move = Move()
            let currentPlayer = players[turnInd]
            highlightPlayer(index: turnInd)
            
            if (currentPlayer.isPlayerRevealed()){
                continue
            }

            if (currentPlayer.name == LoginViewController.getUsername() && didPlayerMove == false){
                enableButtons()
                break
            } else if (currentPlayer.name == LoginViewController.getUsername()) {
                disableAllButtons()
                curMove = playerMove
                didPlayerMove = false
            } else {
                curMove = currentPlayer.getPlayerMove()
            }
            
            sleep(1)
            statusLabel.text = curMove.toString() //updates label
            //curMove is now set
            moveLog.append(curMove)
            //checking for challenges
            let objection = anyChallenges(move: curMove) //move
            statusLabel.text = objection.toString()
            sleep(1)
            
            if (objection.name == "challenge"){
                statusLabel.text = objection.challengeString()
                sleep(1)
                if currentPlayer.checkhaveCard(moveName: curMove.name){//fix up in player class
                    objection.caller.revealCard()
                }
                else{
                    objection.target.revealCard() //reveal card must present modally
                }
                sleep(1)
            }
            
            if (objection.name == "allow"){
                statusLabel.text = curMove.successfulString()
                actOnMove(move: curMove)
            }
            
            /*
             For block, we also need to figure out how to incorporate extra buttons 
             if (objection.name == "block"){
                statusLabel update
                move = lastRoundOfAnyChallenges() method
                if move.name == "allow" ...
                if move.name == "challenge" ...
             }
             */
            isGameOver(gameOn: &gameOn)
            incrementInd()
        }
    }
    
    func isGameOver(gameOn: inout Bool){
        var countFalse: Int = 0
        for cur in players{
            if cur.isPlayerRevealed(){
                countFalse += 1
            }
        }
        if (countFalse == 1){
            gameOn = false
        }
    }
    
    //still need to update the labels!
    func revealCard(curPlayer: Player){
        if (curPlayer.name == LoginViewController.getUsername()){
            //create alert message here!!
        }
        else{
            if (!curPlayer.cards.0.revealed){
                statusLabel.text = "\(curPlayer.name) fails challenge and reveals his \(curPlayer.cards.0.name ?? "error") card."
                curPlayer.cards.0.revealed = true
            }
            else if (!curPlayer.cards.1.revealed){
                statusLabel.text = "\(curPlayer.name) fails challenge and reveals his \(curPlayer.cards.1.name ?? "error") card."
                curPlayer.cards.1.revealed = true
            }
        }
        tableView.reloadData()
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
    
    //Julie highlighting
    func anyChallenges(move: Move) -> Move{
        var curMove: Move = Move()
        challengeTurnInd = 0
        while challengeTurnInd < players.count{
            let player = players[challengeTurnInd]
            if (player.name == move.caller.name){
                challengeTurnInd += 1
                continue
            }
            if (player.name == LoginViewController.getUsername()){
                enableChallengeButtons()
                break
            } else{
                curMove = player.getChallengeOrAllow(target: move.caller)
            }
            if (didPlayerChallengeOrAllow){
                curMove = challengeMove
            }
            if (curMove.name == "challenge"){
                return curMove
            }
            challengeTurnInd += 1
        }
        return curMove
    }
    
    func incrementInd() {
        turnInd += 1
        if turnInd >= players.count{
            turnInd = 0
        }
    }
    
    // MARK: - Buttons
        
    @IBAction func coupBtnPressed(_ sender: Any) { //how do we select target
        if (targetInd != -1){
            didPlayerMove = true
            playerMove = Move(name: "coup", caller: players[turnInd], target: players[targetInd])
            runGame()
        }
    }
    
    @IBAction func taxBtnPressed(_ sender: Any) {
        didPlayerMove = true
        playerMove = Move(name: "tax", caller: players[turnInd], target: players[turnInd])
        runGame()
    }
    
    @IBAction func stealBtnPressed(_ sender: Any) {
        if (targetInd != -1){
            didPlayerMove = true
            playerMove = Move(name: "steal", caller: players[turnInd], target: players[targetInd])
            runGame()
        }
    }
    
    @IBAction func assassinateBtnPressed(_ sender: Any) {
        if (targetInd != -1){
            didPlayerMove = true
            playerMove = Move(name: "assassinate", caller: players[turnInd], target: players[targetInd])
            runGame()
        }
    }
    
    @IBAction func allowBtnPressed(_ sender: Any) {
        didPlayerChallengeOrAllow = true
        challengeMove = Move(name: "allow", caller: players[challengeTurnInd], target: players[turnInd])
    }
    
    @IBAction func incomeBtnPressed(_ sender: Any) {
        didPlayerMove = true
        playerMove = Move(name: "income", caller: players[turnInd], target: players[turnInd])
        runGame()
    }
    
    @IBAction func foreignBtnPressed(_ sender: Any) {
        didPlayerMove = true
        playerMove = Move(name: "foreignAid", caller: players[turnInd], target: players[turnInd])
        runGame()
    }
    
    @IBAction func exchangeBtnPressed(_ sender: Any) {
        didPlayerMove = true
        playerMove = Move(name: "exchange", caller: players[turnInd], target: players[turnInd])
        runGame()
        //intiate segue here
    }
    
    @IBAction func challengeBtnPressed(_ sender: Any) {
        didPlayerChallengeOrAllow = true
        challengeMove = Move(name: "challenge", caller: players[challengeTurnInd], target: players[turnInd])
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
    
    func disableAllButtons(){
        coupBtn.isEnabled = false
        taxBtn.isEnabled = false
        stealBtn.isEnabled = false
        assassinateBtn.isEnabled = false
        foreignBtn.isEnabled = false
        incomeBtn.isEnabled = false
        exchangeBtn.isEnabled = false
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AIs.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // write the code you want to implement when the cell was selected
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gameLogTableViewCell", for: indexPath) as! GameLogTableViewCell
        
        let row = indexPath.row
        
        // Configure the cell...
        cell.aiImageView.image = AIs[row].photo
        cell.aiNameLabel.text = AIs[row].name
        cell.moneyLabel.text = "$ \(AIs[row].coins)"
        
        if AIs[row].cards.0.revealed {
            cell.identity1Label.text = AIs[row].cards.0.name
            cell.identity1Label.textColor = UIColor.label
        } else {
            cell.identity1Label.text = "Hidden"
            cell.identity1Label.textColor = UIColor(white: 0.5, alpha: 0.5)
        }
        
        if AIs[row].cards.1.revealed {
            cell.identity2Label.text = AIs[row].cards.1.name
            cell.identity2Label.textColor = UIColor.label
        } else {
            cell.identity2Label.text = "Hidden"
            cell.identity2Label.textColor = UIColor(white: 0.5, alpha: 0.5)
        }
        
        cell.contentView.backgroundColor = AICellColors[row]
        return cell
    }
    
    // MARK: - Table Colors
    func addAIColors() {
        for _ in 1...AIs.count {
            AICellColors.append(UIColor.clear)
        }
    }
    
    func highlightUser() {
        userCellColor = UIColor.gray
        userStack.backgroundColor = userCellColor
    }
    
    func highlightAI(index: Int) {
        AICellColors[index] = UIColor.gray
        tableView.reloadData()
    }
    
    func highlightPlayer(index: Int) {
        if index == 0 {
            highlightUser()
        } else {
            highlightAI(index: index - 1)
        }
    }
    
    func dismissHighlights() {
        userCellColor = UIColor.clear
        userStack.backgroundColor = userCellColor
        
        for i in 1...AICellColors.count {
            AICellColors[i - 1] = UIColor.clear
        }
        tableView.reloadData()
    }
    
    // MARK: - Segues

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
    
    func youWon() {
        statusLabel.text = "You Won"
    }
}
