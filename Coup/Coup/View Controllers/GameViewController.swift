import UIKit

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
    var deck: Deck?
    var twoCards: (Card, Card)?
    var userCard: Card?
    var caseNum: Int?
    var switchSegue = false
    
    var user: Player?
    var AIs: [Player] = []
    
    var playerMove = Move()
    var didPlayerMove = false
    var turnInd = 0
    var didPlayerChallengeOrAllow = false
    var challengeTurnInd = 0
    var challengeMove = Move()
    
    //boolean values for each move, and then this is set everytime a button is clicked
    var steal = false
    var assassinate = false
    var coup = false
    
    //steal is not always possible, when others players do not have enough money to steal from
    var isStealPossible: Bool = false
    
    var target: Player?{
        didSet{
            //this ensures the whenever the player move is set, we have a target
            didPlayerMove = true
            
            if steal{
                playerMove = Move(name: "steal", caller: players[turnInd], target: (self.target!))
            } else if coup {
                playerMove = Move(name: "coup", caller: players[turnInd], target: (self.target!))
            } else {
                playerMove = Move(name: "assassinate", caller: players[turnInd], target: (self.target!))
            }
            queueForGame.async(execute: workingItem)
        }
        
        willSet{}
    }
    
    //custom thread for gameplay
    var queueForGame = DispatchQueue(label: "queueForGame")
    var workingItem:DispatchWorkItem!
    
    var status = "You Lost"
    var userCellColor = UIColor.clear
    var AICellColors: [UIColor] = []
    
    var currentUserCard1 = UIImage(named: "Card Back")
    var currentUserCard2 = UIImage(named: "Card Back")
    var gameOn = true
    
    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        disableAllButtons()
        
        //deck initialization
        deck = Deck()
        deck!.assign2Cards(players: players)
        
        // for tableView
        tableView.delegate = self
        tableView.dataSource = self
        
        setupAIs()
        setupUser()
        
        // runGame begins
        workingItem = DispatchWorkItem {
            self.runGame()
        }
        queueForGame.async(execute: workingItem)
        
        setUpUI()
        setUpMode()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setUpMode()
    }
    
    func setUpUI() {
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
    
    func setUpMode() {
        if SettingsViewController.isLightModeEnabled() {
            overrideUserInterfaceStyle = .light
            self.view.backgroundColor = UIColor(hex: "#FFF8E1FF")
        } else {
            overrideUserInterfaceStyle = .dark
            self.view.backgroundColor = UIColor(hex: "#283747FF")
        }
    }
    
    func setupAIs() {
        AIs = players
        AIs.remove(at: 0) //removes the user object, so it is just AIs
        addAIColors()
    }
    
    //updates user UI, so it reflects gamestate accurately
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
    
    func runGame() {
        while gameOn {
            var curMove: Move = Move()
            let currentPlayer = players[turnInd]
            
            // If this players is fully revealed, skip this player's turn
            if currentPlayer.isPlayerRevealed() {
                incrementInd()
                continue
            }
            
            //all UI updates, are placed in main queue
            DispatchQueue.main.async {
                self.dismissHighlights()
                self.highlightPlayerInGray(index: self.turnInd)
            }
            sleep(1)
            
            //if it is the players turn
            if (currentPlayer.name == LoginViewController.getUsername() && didPlayerMove == false){
                DispatchQueue.main.async {
                    self.statusLabel.text = "Your turn. Select a move."
                    self.enableButtons(currentPlayer: currentPlayer)
                }
                sleep(3)
                break
            } else if (currentPlayer.name == LoginViewController.getUsername()) { //user has selected a move
                curMove = playerMove //user move is stored in curMove
                didPlayerMove = false
            } else { //else we get a move from the AI
                curMove = currentPlayer.getPlayerMove()
            }
            
            DispatchQueue.main.async {
                self.statusLabel.text = curMove.toString()
            }
            sleep(3)
            moveLog.append(curMove)
            
            //cannot challenge income or coup
            var objection: Move = Move()
            if (curMove.name != "income" && curMove.name != "coup") {
                objection = anyChallenges(move: curMove) //checks for challenges
                if (objection.name == "challenge"){
                    DispatchQueue.main.async {
                        self.statusLabel.text = objection.challengeString()
                        Sound.playChallenge()
                    }
                    sleep(3)
                    
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
                            self.statusLabel.text = "\(currentPlayer.name) won the challenge.\n \(currentPlayer.name)'s action will be taken."
                        }
                        sleep(3)
                        
                        self.actOnMove(move: curMove)
                        
                        print("cardDeck: \(deck!.cardDeck)")
                        
                        DispatchQueue.main.async {
                            self.setupUser()
                            self.tableView.reloadData()
                        }
                        sleep(2)
                        
                        DispatchQueue.main.async {
                            self.statusLabel.text = "\(currentPlayer.name) won the challenge.\n New card will be given to \(currentPlayer.name)."
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
                        
                        print("cardDeck: \(deck!.cardDeck)")
                        
                        DispatchQueue.main.async {
                            self.setupUser()
                            self.tableView.reloadData()
                        }
                        sleep(2)
                    }
                    else{
                        revealCard(curPlayer: objection.target)
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
                Sound.stopPlay()
                self.performSegue(withIdentifier: "gameEndsSegueIdentifier", sender: nil)
            }
        }
    }
    
    func isGameOver(gameOn: inout Bool) {
        var countFalse = 0
        for cur in players{
            if cur.isPlayerRevealed() {
                countFalse += 1
            }
        }
        if (countFalse == players.count - 1 || user!.isPlayerRevealed()) {
            gameOn = false
            if players[0].isPlayerRevealed() {
                DispatchQueue.main.sync {
                    self.youLose()
                    Sound.stopPlay()
                    self.performSegue(withIdentifier: "gameEndsSegueIdentifier", sender: nil)
                }
            } else {
                DispatchQueue.main.sync {
                    self.youWon()
                    Sound.stopPlay()
                    self.performSegue(withIdentifier: "gameEndsSegueIdentifier", sender: nil)
                }
            }
        }
    }
    
    func revealCard(curPlayer: Player) {
        let mostRecentMove: String = moveLog[moveLog.count - 1].name
        if (!curPlayer.cards.0.revealed) {
            DispatchQueue.main.async {
                if curPlayer.name == LoginViewController.getUsername() {
                    self.revealFirstCard()
                }
                if (mostRecentMove == "coup" || mostRecentMove == "assassinate"){
                    self.statusLabel.text = "\(curPlayer.name) reveals the \(curPlayer.cards.0.name ?? "error")."
                }
                else{
                    self.statusLabel.text = "\(curPlayer.name) fails challenge\n and reveals the \(curPlayer.cards.0.name ?? "error") card."
                }
            }
            sleep(2)
            curPlayer.cards.0.revealed = true
            
        } else if (!curPlayer.cards.1.revealed) {
            DispatchQueue.main.async {
                if curPlayer.name == LoginViewController.getUsername() {
                    self.revealSecondCard()
                }
                if (mostRecentMove == "coup" || mostRecentMove == "assassinate"){
                    self.statusLabel.text = "\(curPlayer.name) reveals the \(curPlayer.cards.1.name ?? "error")."
                }
                else{
                    self.statusLabel.text = "\(curPlayer.name) fails challenge\n and reveals the \(curPlayer.cards.1.name ?? "error") card."
                }
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
                Sound.playIncome()
            }
            sleep(1)
        case "foreignAid":
            move.caller.coins += 2
            DispatchQueue.main.async {
                Sound.playIncome()
            }
            sleep(1)
        case "coup":
            move.caller.coins -= 7
            revealCard(curPlayer: move.target)
        case "exchange":
            DispatchQueue.main.async {
                Sound.playExchange()
            }
            sleep(1)
            
            twoCards = deck!.give2Cards()
            let caller = move.caller
            
            if caller.name == LoginViewController.getUsername() {
                // if the caller's first card has not revealed yet,
                // give them a chance to exchange it for another one from twoCards
                switchSegue = false
                
                if self.user!.cards.0.revealed == false {
                    DispatchQueue.main.sync {
                        self.userCard = self.user!.cards.0
                        self.caseNum = 0
                        self.performSegue(withIdentifier: "exchangeSegueIdentifier", sender: nil)
                    }
                    
                    while (!switchSegue) {}
                }
                
                if self.user!.cards.1.revealed == false {
                    DispatchQueue.main.sync {
                        // if the caller's second card has not revealed yet,
                        // give them a chance to exchange it for another one from twoCards
                        self.userCard = self.user!.cards.1
                        self.caseNum = 2
                        self.performSegue(withIdentifier: "exchangeSegueIdentifier", sender: nil)
                    }
                    sleep(1)
                    
                    switchSegue = false
                    while (!switchSegue) {}
                    sleep(1)
                    switchSegue = false
                }
                
                DispatchQueue.main.async {
                    self.setupUser()
                }
                sleep(2)
                
            } else {
                var temp = Card()
                
                if !caller.cards.0.revealed{
                    temp = caller.cards.0
                    caller.cards.0 = twoCards!.0
                    twoCards!.0 = temp
                }
                if !caller.cards.1.revealed{
                    temp = caller.cards.1
                    caller.cards.1 = twoCards!.1
                    twoCards!.1 = temp
                }
            }
            
            deck!.get2CardsBackNShuffle(twoCards: twoCards!)
            
        case "assassinate":
            DispatchQueue.main.async {
                Sound.playKill()
            }
            sleep(1)
            
            move.caller.coins -= 3
            revealCard(curPlayer: move.target)
        case "steal":
            move.target.coins -= 2
            move.caller.coins += 2
            DispatchQueue.main.async {
                Sound.playIncome()
            }
            sleep(1)
        case "tax":
            move.caller.coins += 3
            DispatchQueue.main.async {
                Sound.playIncome()
            }
            sleep(1)
        default:
            break
        }
    }
    
    func anyChallenges(move: Move) -> Move {
        var curMove: Move = Move()
        challengeTurnInd = 0
        
        while challengeTurnInd < players.count {
            let player = players[challengeTurnInd]
            didPlayerChallengeOrAllow = false
            
            if (player.name == move.caller.name || player.isPlayerRevealed()){
                challengeTurnInd += 1
                continue
            }
            
            DispatchQueue.main.async {
                self.highlightPlayerInYellow(index: self.challengeTurnInd)
            }
            sleep(2)
            
            if (player.name == LoginViewController.getUsername()){
                
                DispatchQueue.main.async {
                    self.statusLabel.text = "Please choose allow or challenge \nwhen it is your turn."
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
                } else {
                    curMove = challengeMove
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
    
    @IBAction func coupBtnPressed(_ sender: Any) {
        if (user!.coins < 7){
            let controller = UIAlertController(title: "You need 7 coins to coup!", message: "", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Ok", style: .default))
            present(controller, animated: true, completion: nil)
            return
        }
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
        self.disableAllButtons()
    }
    
    @IBAction func taxBtnPressed(_ sender: Any) {
        didPlayerMove = true
        playerMove = Move(name: "tax", caller: players[turnInd], target: players[turnInd])
        queueForGame.async(execute: workingItem)
        self.disableAllButtons()
    }
    
    @IBAction func stealBtnPressed(_ sender: Any) {
        if (!isStealPossible){
            let controller = UIAlertController(title: "Nobody has enough coins to steal from!", message: "", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Ok", style: .default))
            present(controller, animated: true, completion: nil)
            return
        }
        let controller = UIAlertController(title: "Set the Target", message: "", preferredStyle: .actionSheet)
        var ind = 1
        for i in AIs {
            if i.isPlayerRevealed() && i.coins >= 2{
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
        if (user!.coins < 3){
            let controller = UIAlertController(title: "You need 3 coins to assassinate!", message: "", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Ok", style: .default))
            present(controller, animated: true, completion: nil)
            return
        }
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
        
        DispatchQueue.main.async {
            Sound.playAllow()
        }
        sleep(1)
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
        self.disableAllButtons()
    }
    
    @IBAction func challengeBtnPressed(_ sender: Any) {
        didPlayerChallengeOrAllow = true
        challengeMove = Move(name: "challenge", caller: players[challengeTurnInd], target: players[turnInd])
        self.disableAllButtons()
    }
    
    func enableButtons(currentPlayer: Player){
        coupBtn.isEnabled = true
        taxBtn.isEnabled = true
        
        
        for i in AIs {
            if i.isPlayerRevealed() {
                continue
            }
            if i.coins >= 2 {
                stealBtn.isEnabled = true
                isStealPossible = true
            }
        }
        
        if (!stealBtn.isEnabled){
            isStealPossible = false
        }
        
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
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AIs.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
        if SettingsViewController.isLightModeEnabled() {
            overrideUserInterfaceStyle = .light
            self.tableView.backgroundColor = UIColor(hex: "#FFF8E1FF")
            cell.backgroundColor = UIColor(hex: "#FFF8E1FF")
        } else {
            overrideUserInterfaceStyle = .dark
            self.tableView.backgroundColor = UIColor(hex: "#283747FF")
            cell.backgroundColor = UIColor(hex: "#283747FF")
        }
        
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
            highlightAI(index: index - 1, color: UIColor(hex: "#7D3C98FF")!)
        }//UIColor(hex: "#FFF8E1FF")
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
