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
        
        arrangeDeck(card: assassin, count: 3)
        arrangeDeck(card: ambassador, count: 3)
        arrangeDeck(card: captain, count: 3)
        arrangeDeck(card: contessa, count: 3)
        arrangeDeck(card: duke, count: 3)
        
    }
    
    func arrangeDeck(card: Card, count: Int) {
        var temp = count
        
        while(temp != 0) {
            while(true) {
                let num = Int.random(in: 0...(cardDeck.count - 1))
                
                if cardDeck[num] as! Int == 0 {
                    cardDeck[num] = card
                    break
                }
            }
            temp -= 1
        }
        
    }
    
    func giveACard() -> Card {
        let card = cardDeck[0]
        cardDeck.remove(at: 0)
        
        return card as! Card
    }
    
    func Give2Roles(deck: Deck) -> (Card, Card) {
        let card1 = cardDeck[0]
        let card2 = cardDeck[1]
        
        return (card1 as! Card, card2 as! Card)
    }
    
    func getCardAndShuffle(deck: Deck, card: Card) {
//        deck.cardDeck.append(card)
//        let cardNum = cardDeck.count
            
    }
    
    func shuffle(deck: Deck) {
//        var newCardDeck = deck.cardDeck
    }

}
