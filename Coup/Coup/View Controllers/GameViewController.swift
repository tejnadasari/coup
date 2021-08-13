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
import AVFoundation

var players: [Player] = []
var moveLog: [Move] = []

protocol ApplyExchangeDelegate {
    func applyExchange(chosenCard: Card, caseNum: Int)
}

protocol SwitchbuttonDelegate {
    func switchButton()
}

class GameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ApplyExchangeDelegate, SwitchbuttonDelegate {
    
    func switchButton() {
        switchSegue = true
    }
    
    
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
    
    
    @IBOutlet weak var cheatSheet: UIButton!
    @IBOutlet weak var logsButton: UIButton!
    @IBOutlet weak var engButton: UIButton!
    
    
            // MARK: - Variables
    var deck: Deck? // deck for game
    var twoCards: (Card, Card)? // twoCards for exchange
    var userCard: Card? // userCard for exchange
    var caseNum: Int?
    var switchSegue = false
    
//    var numPlayers: Int? //this will be set in a prepare function in the previous VC
    //var players: [Player] = [] //this is set in previous VC
    var user: Player?
    var AIs: [Player] = []
    
    var playerMove = Move() //this is the move the player chooses
    var didPlayerMove = false //did the player select a move yet
    var turnInd = 0 //current turn
    var didPlayerChallengeOrAllow = false
    var challengeTurnInd = 0 //whose turn it is to select challenge or allow
    var challengeMove = Move() //this is the move that is chosen for challenge/allow
    var targetInd = -1 //the index in the players array of whoever is being targeted
    
    //a bunch of boolean values for each move, and then this is set everytime a button is clicked
    //steal, assassinate, and coup
    var steal = false
    var assassinate = false
    var coup = false
    
    var target: Player?{
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
    
    static var audioPlayer: AVAudioPlayer?
    var gameOn = true
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        disableAllButtons()

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
        
        coupBtn.layer.cornerRadius = 15
        coupBtn.layer.borderWidth = 2
        coupBtn.layer.borderColor = UIColor.black.cgColor

        taxBtn.layer.cornerRadius = 15
        taxBtn.layer.borderWidth = 2
        taxBtn.layer.borderColor = UIColor.black.cgColor
        
        stealBtn.layer.cornerRadius = 15
        stealBtn.layer.borderWidth = 2
        stealBtn.layer.borderColor = UIColor.black.cgColor
        
        assassinateBtn.layer.cornerRadius = 15
        assassinateBtn.layer.borderWidth = 2
        assassinateBtn.layer.borderColor = UIColor.black.cgColor
        
        allowBtn.layer.cornerRadius = 15
        allowBtn.layer.borderWidth = 2
        allowBtn.layer.borderColor = UIColor.black.cgColor
        
        incomeBtn.layer.cornerRadius = 15
        incomeBtn.layer.borderWidth = 2
        incomeBtn.layer.borderColor = UIColor.black.cgColor
        
        exchangeBtn.layer.cornerRadius = 15
        exchangeBtn.layer.borderWidth = 2
        exchangeBtn.layer.borderColor = UIColor.black.cgColor
        
        challengeBtn.layer.cornerRadius = 15
        challengeBtn.layer.borderWidth = 2
        challengeBtn.layer.borderColor = UIColor.black.cgColor
        
        foreignBtn.layer.cornerRadius = 15
        foreignBtn.layer.borderWidth = 2
        foreignBtn.layer.borderColor = UIColor.black.cgColor
        
        
        cheatSheet.layer.cornerRadius = 15
        cheatSheet.layer.borderWidth = 2
        cheatSheet.layer.borderColor = UIColor.black.cgColor
        
        logsButton.layer.cornerRadius = 15
        logsButton.layer.borderWidth = 2
        logsButton.layer.borderColor = UIColor.black.cgColor
        
        engButton.layer.cornerRadius = 15
        engButton.layer.borderWidth = 2
        engButton.layer.borderColor = UIColor.black.cgColor
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
        while gameOn {
            DispatchQueue.main.async {
                self.dismissHighlights()
                self.playGame()
            }
            sleep(1)
            
            var curMove: Move = Move()
            let currentPlayer = players[turnInd]
            
            // If this players is knocked out, skip this player's turn
            if currentPlayer.isPlayerRevealed() {
                continue
            }
            
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
                sleep(3)
                
                break
            } else if (currentPlayer.name == LoginViewController.getUsername()) {
                DispatchQueue.main.async {
                    self.disableAllButtons()
                }
                sleep(1)
                
                curMove = playerMove
                didPlayerMove = false
            } else {
                curMove = currentPlayer.getPlayerMove()
            }
            
            DispatchQueue.main.async {
               self.statusLabel.text = curMove.toString() //updates strings properly
            }
            sleep(3)
            
            //curMove is now set
            moveLog.append(curMove)
            //checking for challenges
             var objection: Move = Move()
            if (curMove.name != "income" && curMove.name != "coup"){
                objection = anyChallenges(move: curMove) //move
                if (objection.name == "challenge"){
                    DispatchQueue.main.async {
                        self.statusLabel.text = objection.challengeString()
                        self.playChallenge()
                    }
                    sleep(3)
                    
                    // if the target win
                    // if the result of checkhaveCardd == -1, the target has the card
                    if currentPlayer.checkhaveCard(moveName: curMove.name) != -1 {
                        let theCard = currentPlayer.checkhaveCard(moveName: curMove.name)
                        revealCard(curPlayer: objection.caller)
                        
//                        // this code is needed -> when the user is the challenger and they fails,
//                        // and two of their cards are revealed, the game should be ended right away.
//                        isGameOver(gameOn: &gameOn)
                        
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
                            self.statusLabel.text = "\(currentPlayer.name) won the challenge. New card will be given"
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
                        DispatchQueue.main.async {
                            self.setupUser()
                        }
                        sleep(1)
                        print("target win")
                    }
                    else{
                        revealCard(curPlayer: objection.target)
                        print("challenger win")
                    }
                }
                if (objection.name == "allow"){
                    DispatchQueue.main.async {
                        self.statusLabel.text = curMove.successfulString()
                    }
                    sleep(1)
                    
                    self.actOnMove(move: curMove)
                    
                    DispatchQueue.main.async {
                        self.setupUser()
                        self.tableView.reloadData()
                    }
                    sleep(2)
                    
                }
            }
            else {
                DispatchQueue.main.async {
                    self.statusLabel.text = curMove.successfulString()
                }
                sleep(1)
                
                self.actOnMove(move: curMove)
                
                DispatchQueue.main.async {
                    self.setupUser()
                    self.tableView.reloadData()
                }
                sleep(2)
            }
            isGameOver(gameOn: &gameOn)
            incrementInd()
        }
        
        if !gameOn {
            DispatchQueue.main.sync {
                GameViewController.stopPlay()
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
            print("DooDoo")
        }
        if (countFalse == players.count - 1 || user!.isPlayerRevealed()) {
            gameOn = false
            print("DaaDaa")
            // TODO Move need moving because seems like user loses when 1 card is revealed
            if players[0].isPlayerRevealed() {
                DispatchQueue.main.sync {
                    self.youLose()
                    GameViewController.stopPlay()
                    self.performSegue(withIdentifier: "gameEndsSegueIdentifier", sender: nil)
                }
            } else {
                DispatchQueue.main.sync {
                    self.youWon()
                    GameViewController.stopPlay()
                    self.performSegue(withIdentifier: "gameEndsSegueIdentifier", sender: nil)
                }
            }
        }
    }
    
    func revealCard(curPlayer: Player) {
        if (!curPlayer.cards.0.revealed) {
            DispatchQueue.main.async {
                if curPlayer.name == LoginViewController.getUsername() {
                    self.revealFirstCard()
                }
                
                self.statusLabel.text = "\(curPlayer.name) exchanges \(curPlayer.cards.0.name ?? "error") for a new role."
            }
            sleep(2)
            curPlayer.cards.0.revealed = true
            
        } else if (!curPlayer.cards.1.revealed) {
            DispatchQueue.main.async {
                if curPlayer.name == LoginViewController.getUsername() {
                    self.revealSecondCard()
                }
                
                self.statusLabel.text = "\(curPlayer.name) exchanges \(curPlayer.cards.1.name ?? "error") for a new role."
            }
            sleep(2)
            
            curPlayer.cards.1.revealed = true
        }
        
        DispatchQueue.main.async {
            self.setupUser()
            self.tableView.reloadData()
        }
        sleep(2)
    }
    
    func actOnMove(move: Move){
        switch move.name {
        case "income":
            move.caller.coins += 1
            DispatchQueue.main.async {
                self.playIncome()
            }
            sleep(1)
        case "foreignAid":
            move.caller.coins += 2
            DispatchQueue.main.async {
                self.playIncome()
            }
            sleep(1)
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
                        print("hi")
                        self.performSegue(withIdentifier: "exchangeSegueIdentifier", sender: nil)
//                        while(!self.switchSegue){}
                    }
                }
                sleep(5)
                
                DispatchQueue.main.async {
                    // if the caller's second card has not revealed yet,
                    // give them a chance to exchange it for another one from twoCards
                    if self.user!.cards.1.revealed == false {
                        self.userCard = self.user!.cards.1
                        self.caseNum = 2
                        self.performSegue(withIdentifier: "exchangeSegueIdentifier", sender: nil)
                        while(!self.switchSegue){}
                    }
                }
                sleep(5)
                
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
            DispatchQueue.main.async {
                self.playIncome()
            }
            sleep(1)
        case "tax":
            move.caller.coins += 3
            DispatchQueue.main.async {
                self.playIncome()
            }
            sleep(1)
        default:
            break
        }
    }
    
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
                    self.statusLabel.text = "Please choose allow or challenge when it is your turn."
                }
                while (!didPlayerChallengeOrAllow){
                    DispatchQueue.main.async {
                        self.enableChallengeButtons()
                    }
                    sleep(1)
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
    
    // MARK: - Sound Effects
    
    func playIncome() {
        GameViewController.playSound(file: "Cash Register")
    }
    
    func playChallenge() {
        GameViewController.playSound(file: "Count Down")
    }
    
    func playGame() {
        GameViewController.playSound(file: "Waiting")
    }
    
    static func playMainSong() {
        GameViewController.playSound(file: "Next Level")
    }
    
    static func stopPlay() {
        GameViewController.audioPlayer?.stop()
    }
    
    static func playSound(file: String) {
        if !SettingsViewController.isSoundEnabled() {
            return
        }

        guard let url = Bundle.main.url(forResource: file, withExtension: "m4a") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            GameViewController.audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)
            guard let audioPlayer = GameViewController.audioPlayer else { return }
            audioPlayer.numberOfLoops = -1
            audioPlayer.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - TableView
    
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
            highlightUser(color: UIColor(red: 41.00, green: 128.00, blue: 185.00, alpha: 1.00))
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
            gameOn = false
            DispatchQueue.main.async {
                GameViewController.stopPlay()
            }
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
