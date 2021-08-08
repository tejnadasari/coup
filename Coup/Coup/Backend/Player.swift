import UIKit

class Player{
    var name: String
    var photo: UIImage
    var cards: (Card, Card)
    var coins = 0
    
    // constructor
    init(name: String, photo: UIImage, cards: (Card, Card)){
        self.name = name
        self.photo = photo
        self.cards = cards
    }
    
    init(){
        name = ""
        photo = UIImage()
        cards = (Card(), Card())
    }
    
    // check out if this player has a specific card or not
    func checkhaveCard(cardName: String) -> Bool{
        if(self.cards.0.name == cardName || self.cards.1.name == cardName){
            return true
        }
        return false
    }
    
    func getPlayerMove() -> Move {
        // Swtich Case statement for chosen Move
        // use multithreading to ask for move and get move
        
        return Move(name: "", caller: Player(name: "", photo: UIImage(named: "Ariana Grande")!, cards: (Card(), Card())), target: Player(name: "", photo: UIImage(named: "Ariana Grande")!, cards: (Card(), Card())))
    }
    
    func updateCoin(coinVal:Int) {
        self.coins = self.coins + coinVal
    }
    
    func getChallengeOrAllow(target: Player) -> Move{
        return Move()
    }
    
    func choose() {
        
    }
    
    func revealCard(){
    }
    
    func otherCardCount(cardLookingFor: String) -> Int{
        var count: Int = 0
        for current in players{
            if (current.name != self.name){
                if (current.cards.0.revealed && current.cards.0.name == cardLookingFor){
                    count += 1
                }
                if (current.cards.1.revealed && current.cards.0.name == cardLookingFor){
                    count += 1
                }
            }
        }
        return count
    }
}

class AI: Player{
    func getAIMove(){
        
    }
    
    
    override func getChallengeOrAllow(target: Player) -> Move {
        return Move(name: "challenge", caller: self, target: target)
    }
}

class realPlayer: Player{
    
}

