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

/* simple comment
 
 1. we need to change highlight thing for challenge turn
 2. make button be pressed only one times except for steal and assassinate
 3. income and coup should not be challenged
 4. exchange doesn't work
    -> For AI, I've already made exchange for AI before but I lost the file so I will implement it tomorrow
 
 
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
    
    //a bunch of boolean values for each move, and then this is set everytime a button is clicked
    //steal, assassinate, and coup
    var steal: Bool = false
    var assassinate: Bool = false
    var coup: Bool = false
    
    var target:Player?{
        didSet{
            print("HOLA didSet")
            didPlayerMove = true
            if steal{
                print("In steal")
                print(self.target!.name)
                playerMove = Move(name: "steal", caller: players[turnInd], target: (self.target!))
            }
            else if coup{
                playerMove = Move(name: "coup", caller: players[turnInd], target: (self.target!))
            }
            else{
                playerMove = Move(name: "assassinate", caller: players[turnInd], target: (self.target!))
            }
            queueForGame.async(execute: workingItem)
        }
        willSet{}
    }
    
    var queueForGame = DispatchQueue(label: "queueForGame")
    var workingItem:DispatchWorkItem!
    
    var status = "You Lost or You Win"
    var userCellColor = UIColor.clear
    var AICellColors: [UIColor] = []
    
    var currentUserCard1 = UIImage(named: "Card Back")
    var currentUserCard2 = UIImage(named: "Card Back")
    
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
        
        workingItem = DispatchWorkItem {
            self.runGame()
        }
        
        queueForGame.async(execute: workingItem)
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
        userCard1Label.textColor = UIColor(white: 0.5, alpha: 0.5)
        card1ImageView.image = currentUserCard1
        userCard2Label.text = user!.cards.1.name!
        userCard2Label.textColor = UIColor(white: 0.5, alpha: 0.5)
        card2ImageView.image = currentUserCard2
        
        if user!.cards.0.revealed {
            userCard1Label.textColor = UIColor.label
        }
        
        if user!.cards.1.revealed {
            userCard2Label.textColor = UIColor.label
        }
    }
    
    // MARK: - Run game
    
    // After assigning 2 cards to each player,
    func runGame(){
         
        var gameOn:Bool = true
        
        while gameOn {
            DispatchQueue.main.async {
                self.dismissHighlights()
            }
            sleep(1)
            
            var curMove: Move = Move()
            let currentPlayer = players[turnInd]
            
            DispatchQueue.main.async {
                self.highlightPlayerInGray(index: self.turnInd)
            }
            sleep(1)
            
            if (currentPlayer.isPlayerRevealed()){
                continue
            }

            if (currentPlayer.name == LoginViewController.getUsername() && didPlayerMove == false){
                DispatchQueue.main.async {
                    self.statusLabel.text = "Your turn. Select a move."
                    self.enableButtons(currentPlayer: currentPlayer)
                 }
                sleep(2)
                
                break
            } else if (currentPlayer.name == LoginViewController.getUsername()) {
                DispatchQueue.main.async {
                    self.disableAllButtons()
                }
                sleep(2)
                
                curMove = playerMove
                didPlayerMove = false
            } else {
                curMove = currentPlayer.getPlayerMove()
            }
            
            DispatchQueue.main.async {
               self.statusLabel.text = curMove.toString() //updates strings properly
            }
            sleep(1)
            
            //curMove is now set
            moveLog.append(curMove)
            //checking for challenges
             var objection: Move = Move()
            if (curMove.name != "income" && curMove.name != "coup"){
                objection = anyChallenges(move: curMove) //move
                if (objection.name == "challenge"){
                    DispatchQueue.main.async {
                        self.statusLabel.text = objection.challengeString()
                    }
                    sleep(2)
                    
                    // if the target win
                    // if the result card.name is not none, the target has the card
                    if currentPlayer.checkhaveCard(moveName: curMove.name) != -1 {
                        let theCard = currentPlayer.checkhaveCard(moveName: curMove.name)
                        revealCard(curPlayer: objection.caller)
                        
                        var newCard = deck!.giveACard()
                        
                        if theCard == 0 {
                            currentPlayer.cards.0.revealed = true
                        } else if theCard == 1 {
                            currentPlayer.cards.1.revealed = true
                        } else {
                            print("Not Applicable")
                        }
                        
                        
                        DispatchQueue.main.async {
                            self.statusLabel.text = "\(currentPlayer.name) won the challenge. \(currentPlayer.name)'s action will be taken"
                        }
                        sleep(3)
                        
                        self.actOnMove(move: curMove)
                        
                        DispatchQueue.main.async {
                            self.statusLabel.text = "\(currentPlayer.name) won the challenge but one of \(currentPlayer.name)'s card is revealed so a new card will be given"
                        }
                        sleep(3)
                        
                        var temp = Card()
                        
                        if theCard == 0 {
                            temp = currentPlayer.cards.0
                            currentPlayer.cards.0 = newCard
                            newCard = temp
                            
                        } else if theCard == 1 {
                            temp = currentPlayer.cards.1
                            currentPlayer.cards.1 = newCard
                            newCard = temp
                            
                        } else {
                            print("Not Applicable")
                        }
                        
                        deck!.get1CardBackNShuffle(oneCard: newCard)
                        
                        print("target win")
                    }
                    else{
                        revealCard(curPlayer: objection.target) //reveal card must present modally
                    }
                }
                if (objection.name == "allow"){
                    DispatchQueue.main.async {
                        self.statusLabel.text = curMove.successfulString()
                        self.actOnMove(move: curMove)
                        self.setupUser()
                        self.tableView.reloadData()
                    }
                    sleep(4)
                }
            }
            else {
                DispatchQueue.main.async {
                    self.statusLabel.text = curMove.successfulString()
                    self.actOnMove(move: curMove)
                    self.setupUser()
                    self.tableView.reloadData()
                }
                sleep(4)
            }
            isGameOver(gameOn: &gameOn)
            incrementInd()
        }
        
        if !gameOn {
            DispatchQueue.main.sync {
                self.performSegue(withIdentifier: "gameEndsSegueIdentifier", sender: nil)
            }
        }
    }
    
    func isGameOver(gameOn: inout Bool) {
        var countFalse = 0
        for cur in players {
            if cur.isPlayerRevealed() {
                countFalse += 1
            }
        }
        if (countFalse == players.count - 1) {
            gameOn = false
            
            // TODO Move need moving because seems like user loses when 1 card is revealed
            if players[0].isPlayerRevealed() {
                DispatchQueue.main.sync {
                    self.youLose()
                    self.performSegue(withIdentifier: "gameEndsSegueIdentifier", sender: nil)
                }
            } else {
                DispatchQueue.main.sync {
                    self.youWon()
                    self.performSegue(withIdentifier: "gameEndsSegueIdentifier", sender: nil)
                }
            }
        }
    }
    
    //still need to update the labels!
    func revealCard(curPlayer: Player) {
        if (!curPlayer.cards.0.revealed) {
            DispatchQueue.main.async {
                self.revealFirstCard()
                self.statusLabel.text = "\(curPlayer.name) fails challenge and reveals his \(curPlayer.cards.0.name ?? "error") card."
            }
            sleep(2)
            
            curPlayer.cards.0.revealed = true
        } else if (!curPlayer.cards.1.revealed) {
            DispatchQueue.main.async {
                self.revealSecondCard()
                self.statusLabel.text = "\(curPlayer.name) fails challenge and reveals his \(curPlayer.cards.1.name ?? "error") card."
            }
            sleep(2)
            
            curPlayer.cards.1.revealed = true
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        sleep(2)
    }
    
    func actOnMove(move: Move){
        switch move.name {
        case "income":
            move.caller.coins += 1
        case "foreignAid":
            move.caller.coins += 2
        case "coup":
            move.caller.coins -= 7
            revealCard(curPlayer: move.target)
        case "exchange":
            // get 2 cards from the current deck
            twoCards = deck!.give2Cards()
            let caller = move.caller
            
            if caller.name == LoginViewController.getUsername() {
                // if the caller's first card has not revealed yet,
                // give them a chance to exchange it for another one from twoCards
                DispatchQueue.main.async {
                    if self.user!.cards.0.revealed == false {
                        self.userCard = self.user!.cards.0
                        self.caseNum = 0
                        self.performSegue(withIdentifier: "exchangeSegueIdentifier", sender: nil)
                    }
                }
                sleep(3)
                
                DispatchQueue.main.async {
                    // if the caller's second card has not revealed yet,
                    // give them a chance to exchange it for another one from twoCards
                    if self.user!.cards.1.revealed == false {
                        self.userCard = self.user!.cards.1
                        self.caseNum = 2
                        self.performSegue(withIdentifier: "exchangeSegueIdentifier", sender: nil)
                    }
                }
                sleep(3)
                
            } else {
                let caseNum = Int.random(in: 0...4)
                var temp = Card()
                
                switch caseNum {
                
                case 0:
                    temp = twoCards!.0
                    twoCards!.0 = caller.cards.0
                    caller.cards.0 = temp
                    
                case 1:
                    temp = twoCards!.1
                    twoCards!.1 = caller.cards.0
                    caller.cards.0 = temp
                    
                case 2:
                    temp = twoCards!.0
                    twoCards!.0 = caller.cards.1
                    caller.cards.1 = temp
                    
                case 3:
                    temp = twoCards!.1
                    twoCards!.1 = caller.cards.1
                    caller.cards.1 = temp
                    
                default:
                    temp = Card()
                }
            }
            
            // give 2 cards back to the current deck -> shuffle activated
            deck!.get2CardsBackNShuffle(twoCards: twoCards!)
            
        case "assassinate":
            move.caller.coins -= 3
            revealCard(curPlayer: move.target)
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
        didPlayerChallengeOrAllow = false
        
        while challengeTurnInd < players.count {
            let player = players[challengeTurnInd]
            
            if (player.name == move.caller.name){
                challengeTurnInd += 1
                continue
            }
            
            DispatchQueue.main.async {
                self.highlightPlayerInYellow(index: self.challengeTurnInd)
            }
            sleep(2)
            
            if (player.name == LoginViewController.getUsername()){
                
                DispatchQueue.main.async {
                    self.statusLabel.text = "Please choose allow or challenge"
                }
                while (!didPlayerChallengeOrAllow){
                    sleep(1)
                    DispatchQueue.main.async {
                        self.enableChallengeButtons()
                    }
                 }
                
            } else {
                curMove = player.getChallengeOrAllow(target: move.caller)
            }
            
            //didPlayerChallenge is already set to false right before this loop
            if (didPlayerChallengeOrAllow){
                if (challengeMove.name == "challenge"){
                    return challengeMove
                }
            }
            else if (curMove.name == "challenge"){
                return curMove
            }
            else{
                curMove = Move(name: "allow", caller: players[challengeTurnInd], target: players[turnInd])
            }
            challengeTurnInd += 1
             DispatchQueue.main.async {
                self.dismissHighlights()
            }
            sleep(1)
         }
        
        return curMove
    }
    
    func incrementInd() {
        turnInd += 1
        if turnInd >= players.count{
            turnInd = 0
        }
    }
    
    func targetMoveSelected(areWeStealing: Bool, areWeKilling: Bool, areWeCoup: Bool){
        self.steal = areWeStealing
        self.assassinate = areWeKilling
        self.coup = areWeCoup
    }
    // MARK: - Buttons
        
    @IBAction func coupBtnPressed(_ sender: Any) { //how do we select target
        let controller = UIAlertController(title: "Set the Target", message: "", preferredStyle: .actionSheet)
        var ind = 1
        for i in AIs {
            if i.isPlayerRevealed(){
                continue
            }
            controller.addAction(UIAlertAction(title: "\(i.name)", style: .default){
            _ in
                self.targetMoveSelected(areWeStealing: false, areWeKilling: false, areWeCoup: true)
                self.target = i
            })
            ind += 1
        }
        present(controller, animated: true, completion: nil)
        //list of variables for each move name, and they will use didSet
        //in didSet, they set self.target, and then self.target uses the movename that has already been set
        self.disableAllButtons()
    }
    
    @IBAction func taxBtnPressed(_ sender: Any) {
        didPlayerMove = true
        playerMove = Move(name: "tax", caller: players[turnInd], target: players[turnInd])
        queueForGame.async(execute: workingItem)
        self.disableAllButtons()
    }
    
    @IBAction func stealBtnPressed(_ sender: Any) {
        let controller = UIAlertController(title: "Set the Target", message: "", preferredStyle: .actionSheet)
        var ind = 1
        for i in AIs {
            if i.isPlayerRevealed(){
                continue
            }
            controller.addAction(UIAlertAction(title: "\(i.name)", style: .default){
            _ in
                self.targetMoveSelected(areWeStealing: true, areWeKilling: false, areWeCoup: false)
                self.target = i
            })
            ind += 1
        }
        present(controller, animated: true, completion: {})
        self.disableAllButtons()
    }
    
    @IBAction func assassinateBtnPressed(_ sender: Any) {
        let controller = UIAlertController(title: "Set the Target", message: "", preferredStyle: .actionSheet)
        var ind = 1
        for i in AIs {
            if i.isPlayerRevealed(){
                continue
            }
            controller.addAction(UIAlertAction(title: "\(i.name)", style: .default){
            _ in
                self.targetMoveSelected(areWeStealing: false, areWeKilling: true, areWeCoup: false)
                self.target = i
            })
            ind += 1
        }
        present(controller, animated: true, completion: nil)
        self.disableAllButtons()
    }
    
    @IBAction func allowBtnPressed(_ sender: Any) {
        didPlayerChallengeOrAllow = true
        challengeMove = Move(name: "allow", caller: players[challengeTurnInd], target: players[turnInd])
        self.disableAllButtons()
     }
    
    @IBAction func incomeBtnPressed(_ sender: Any) {
        didPlayerMove = true
        playerMove = Move(name: "income", caller: players[turnInd], target: players[turnInd])
        queueForGame.async(execute: workingItem)
        self.disableAllButtons()
    }
    
    @IBAction func foreignBtnPressed(_ sender: Any) {
        didPlayerMove = true
        playerMove = Move(name: "foreignAid", caller: players[turnInd], target: players[turnInd])
        queueForGame.async(execute: workingItem)
        self.disableAllButtons()
    }
    
    @IBAction func exchangeBtnPressed(_ sender: Any) {
        didPlayerMove = true
        playerMove = Move(name: "exchange", caller: players[turnInd], target: players[turnInd])
        queueForGame.async(execute: workingItem)
        //intiate segue here
        self.disableAllButtons()
    }
    
    @IBAction func challengeBtnPressed(_ sender: Any) {
        didPlayerChallengeOrAllow = true
        challengeMove = Move(name: "challenge", caller: players[challengeTurnInd], target: players[turnInd])
        self.disableAllButtons()
    }
    
    func enableButtons(currentPlayer: Player){
        if currentPlayer.coins >= 7 {
            coupBtn.isEnabled = true
        }
        
        taxBtn.isEnabled = true
        stealBtn.isEnabled = true
        
        if currentPlayer.coins >= 3 {
            assassinateBtn.isEnabled = true
        }
        
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
    
//    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
    
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
            cell.identity1Label.textColor = UIColor(white: 0.7, alpha: 0.5)
        }
        
        if AIs[row].cards.1.revealed {
            cell.identity2Label.text = AIs[row].cards.1.name
            cell.identity2Label.textColor = UIColor.label
        } else {
            cell.identity2Label.text = "Hidden"
            cell.identity2Label.textColor = UIColor(white: 0.7, alpha: 0.5)
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
    
    func highlightUser(color: UIColor) {
        userCellColor = color
        userStack.backgroundColor = userCellColor
    }
    
    func highlightAI(index: Int, color: UIColor) {
        AICellColors[index] = color
        tableView.reloadData()
    }
    
    func highlightPlayerInGray(index: Int) {
        if index == 0 {
            highlightUser(color: UIColor.lightGray)
        } else {
            highlightAI(index: index - 1, color: UIColor.lightGray)
        }
    }
    
    func highlightPlayerInYellow(index: Int) {
        if index == 0 {
            highlightUser(color: UIColor.yellow)
        } else {
            highlightAI(index: index - 1, color: UIColor.yellow)
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
    
    // MARK: - Reveal user cards
    func revealFirstCard() {
        DispatchQueue.main.async {
            let image = self.user!.cards.0.photo
            self.currentUserCard1 = image
            self.card1ImageView.image = image
            UIView.transition(with: self.card1ImageView, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        }
    }
    
    func revealSecondCard() {
        DispatchQueue.main.async {
            let image = self.user!.cards.1.photo
            self.currentUserCard2 = image
            self.card2ImageView.image = image
            UIView.transition(with: self.card2ImageView, duration: 0.3, options: .transitionFlipFromLeft, animations: nil, completion: nil)
        }
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
        
        else if segue.identifier == "gameEndsSegueIdentifier" {
            GameEndsViewController.status = status
        }
    }
    
    func youLose() {
        status = "You Lose"
        statusLabel.text = status
        GameEndsViewController.status = status
    }
    
    func youWon() {
        status = "You Won"
        statusLabel.text = status
        GameEndsViewController.status = status
    }
}
