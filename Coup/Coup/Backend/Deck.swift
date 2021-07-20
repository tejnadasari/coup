/*
 
 Assassin
 Ambassador
 Captain
 Contessa
 Duke
 
 */

class Deck{
    var cardDeck = [Any](repeating: 0, count: 15)
    var count = 3
    
    init() {
        makeDeck()
    }
    
    func makeDeck() {
        let assassin = Assassin()
        let ambassador = Ambassador()
        let captain = Captain()
        let contessa = Contessa()
        let duke = Duke()
        
        shuffleDeck3(card: assassin)
        shuffleDeck3(card: ambassador)
        shuffleDeck3(card: captain)
        shuffleDeck3(card: contessa)
        shuffleDeck3(card: duke)
        
    }
    
    func shuffleDeck3(card: Card) {
        while(count != 0) {
            while(true) {
                let num = Int.random(in: 0...14)
                
                if cardDeck[num] as! Int == 0 {
                    cardDeck[num] = card
                    break
                }
            }
            count -= 1
        }
        
    }
    
    func giveACard() -> Card {
        let card = cardDeck[0]
        cardDeck.remove(at: 0)
        
        return card as! Card
    }
    
//    func shuffleAndGive() {
//
//    }

}
