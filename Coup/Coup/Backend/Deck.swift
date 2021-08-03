/*
 
 Assassin
 Ambassador
 Captain
 Contessa
 Duke
 
 */

class Deck{
    var cardDeck = [Any](repeating: 0, count: 15)
    
    // MARK:- constructor of Deck
    init() {
        makeDeck()
    }
    
    // Literally, make deck
    func makeDeck() {
        let assassin = Assassin()
        let ambassador = Ambassador()
        let captain = Captain()
        let contessa = Contessa()
        let duke = Duke()
        
        shuffleDeck(cardDeck: &self.cardDeck, card: assassin, count: 3)
        shuffleDeck(cardDeck: &self.cardDeck, card: ambassador, count: 3)
        shuffleDeck(cardDeck: &self.cardDeck, card: captain, count: 3)
        shuffleDeck(cardDeck: &self.cardDeck, card: contessa, count: 3)
        shuffleDeck(cardDeck: &self.cardDeck, card: duke, count: 3)
        
    }
    
    // Literally, shuffle deck
    func shuffleDeck(cardDeck: inout [Any], card: Card, count: Int) {
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
    
    // MARK:- Function for attributing cards to each player
    
    // give a card to users when kicking off the game
    func giveACard() -> Card {
        let num = Int.random(in: 0...(self.cardDeck.count - 1))
        let card = self.cardDeck[num]
        
        self.cardDeck.remove(at: num)
        
        return card as! Card
    }
    
    // MARK:- Function for exchange2Roles of Ambassador
    
    // give 2 cards to the user acting 'exchange2Roles'
    func give2Cards() -> (Card, Card) {
        let num1 = Int.random(in: 0...(self.cardDeck.count - 1))
        let card1 = self.cardDeck[num1]
        self.cardDeck.remove(at: num1)
        
        let num2 = Int.random(in: 0...(self.cardDeck.count - 1))
        let card2 = self.cardDeck[num2]
        self.cardDeck.remove(at: num2)
        
        return (card1 as! Card, card2 as! Card)
    }
    
    // get 2 cards back from the user who acted 'exchange2Roles' and shuffle the deck
    func get2CardsBackNShuffle(twoCards: (Card, Card)) {
        self.cardDeck.append(twoCards.0)
        self.cardDeck.append(twoCards.1)
        
        shuffle()
    }
    
    // shuffle the cardDeck
    func shuffle() {
        var newCardDeck = [Any](repeating: 0, count: self.cardDeck.count)
        
        for i in 0...self.cardDeck.count {
            shuffleDeck(cardDeck: &newCardDeck, card: self.cardDeck[i] as! Card, count: 1)
        }
        
        self.cardDeck = newCardDeck
    }
    
    // MARK:- Function for challenge situation
    
    // when the challenge was failed, the card the targted player revealed will be
    // shuffled back to the deck and they get a new card
    func get1CardBackNShuffle(oneCard: Card) {
        self.cardDeck.append(oneCard)
        
        shuffle()
    }
    
    func giveANewCard() -> Card {
        let num = Int.random(in: 0...(self.cardDeck.count - 1))
        let newCard = self.cardDeck[num]
        
        return newCard as! Card
    }

}
