class Player{
    var name: String
    var photo: String
    var coins: Int
    var cards: Tuple
    var move: String
    
    init(name: String, photo: String, coins: String, cards: (String, String), move:(String)){
        self.name = String
        self.photo = String
        self.coins = String
        self.cards = (String, String)
    }
    
    func haveCard(checkName:String) -> Bool{
        if(self.cards.0 == checkName || self.cards.1 == checkName){
            return true
        }
        return false
    }
    
    func getPlayerMove(){
        //Swtich Case statement for chosen Move
    }
    
    func askPlayerMove(){
        
    }
    
    func updateCoin(coinVal:Int){
        self.coins = self.coins + coinVal
    }
    
    func getChallengeOrAllow(){
        
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

