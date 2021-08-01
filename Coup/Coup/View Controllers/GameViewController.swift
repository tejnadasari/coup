/*
 How will gameplay work:
 
 Previous view controller will initialize: numberOfAI
 
 Deck, and AI array will be initialized.
 
 ViewDidLoad will call runGame() method, will also be in this file
 
 RunGame() will consist of a while loop (moving the Game backend to this file)
    Within this loop, we need to find a way to pause the gameplay to allow the
    user to click a button. Potentially will use the willSet and didSet properties
    of a boolean variable. May use "await" keyword as well. Currently researching
    concurrency. 
 
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
    var players: [Player] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePlayers()
        deck = Deck()
        runGame()
    }
    
    func initializePlayers() {
        if (numPlayers == nil){
            return
        }
        players.append(realPlayer(name: "Xinyi", photo: "", cards: (Card(),Card())))
        
        for n in 2...numPlayers! {
            players.append(AI(name: "", photo: "", cards: (Card(),Card())))
        }
    }
    
    func runGame(){
        
        var keepGoing:Bool = true
        
        while keepGoing{
            
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
