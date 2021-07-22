class Player{
    var name: String
    var photo: String
    var cards: (Card, Card)
    
    var coins = 0
    
    init(name: String, photo: String, cards: (Card, Card)){
        self.name = name
        self.photo = photo
        self.cards = cards
    }
    
    func haveCard(checkName: String) -> Bool{
        if(self.cards.0.name == checkName || self.cards.1.name == checkName){
            return true
        }
        return false
    }
    
    func getPlayerMove() -> Move {
        //Swtich Case statement for chosen Move
        // use multithreading to ask for move and get move
        
        return Move(name: "", caller: Player(name: "", photo: "", cards: (Card(), Card())), target: Player(name: "", photo: "", cards: (Card(), Card())))
    }
    
    func updateCoin(coinVal:Int) {
        self.coins = self.coins + coinVal
    }
    
    func getChallengeOrAllow(){
        
    }
    
    func choose() {
        
    }
    
    func revealCard(){
        
    }
}

class AI: Player{
    func getAIMove(){
        
    }
}

class realPlayer: Player{
    
}

