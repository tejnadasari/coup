import UIKit

class Player{
    var name: String
    var photo: UIImage
    var cards: (Card, Card)
    var coins = 2
    
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
    
    func checkhaveCard(moveName: String) -> Int{
        var theCard = -1
        
        switch moveName{
        case "assassinate":
            if self.cards.0.assassinate! || self.cards.1.assassinate!
            {
                if self.cards.0.assassinate! {
                    theCard = 0
                } else {
                    theCard = 1
                }
            }
        case "tax":
            if self.cards.0.tax! || self.cards.1.tax!
            {
                if self.cards.0.tax! {
                    theCard = 0
                } else {
                    theCard = 1
                }
            }
        case "steal":
            if self.cards.0.steal! || self.cards.1.steal!
            {
                if self.cards.0.steal! {
                    theCard = 0
                } else {
                    theCard = 1
                }
            }
        case "exchange":
            if self.cards.0.exchange! || self.cards.1.exchange!
            {
                if self.cards.0.exchange! {
                    theCard = 0
                } else {
                    theCard = 1
                }
            }
        case "coup":
            if self.cards.0.coup! || self.cards.1.coup!
            {
                if self.cards.0.coup! {
                    theCard = 0
                } else {
                    theCard = 1
                }
            }
        case "foreignAid":
            if self.cards.0.foreignAid! || self.cards.1.foreignAid!
            {
                if self.cards.0.foreignAid! {
                    theCard = 0
                } else {
                    theCard = 1
                }
            }
        default:
            print("Not Applicable")
        }
        
        return theCard
    }
    
    func isPlayerRevealed() -> Bool{
        return (self.cards.0.revealed && self.cards.1.revealed)
    }
    
    func updateCoin(coinVal:Int) {
        self.coins = self.coins + coinVal
    }

//    func choose() {
//
//    }
    
//    func revealCard() {  // TODO
//    }
    
    func otherCardCount(cardLookingFor: String) -> Int{
        var count: Int = 0
        for current in players {
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
    
    // MARK: - Only for AIs
    
    func getPlayerMove() -> Move {  // only for AI
        print("This should never happen")
        return Move()
    }
    
    func getChallengeOrAllow(target: Player) -> Move {  // only for AI
        print("This should never happen")
        return Move()
    }
}

class AI: Player{
    
    var moveRateDic: [String:Int] = ["income":5, "foreignAid":5, "tax":5, "steal":5, "assassinate":5, "exchange":5]
    
    var challengeRate = 0.25

    // MARK:- getAIMoveName and getPlayerMove
    
    // Let's get the name of Move first and then, let's figure out the target
    func getAIMoveName() -> String {
        //exclude the moves challenge / allow
        //changeMoverate(), then loop through dictionary to find move with highest rating
        changeMoveRate()
        
        var aiMoveName = "income"
        var total = 0
        
        for (_, value) in moveRateDic {
            total += value
        }
                
        let rand = Int.random(in: 0...total)
        
        var lowerbound = 0
        var upperbound = 0
        
        for (key, value) in moveRateDic {
            upperbound += value
            
            if lowerbound < rand && rand <= upperbound {
                aiMoveName = key
            }
            
            lowerbound += value
        }
        
        // as soon as 7+ dollars have been accumulated, initiate coup
        // (lean towards person that is about to be knocked out)
        if self.coins >= 7 {
            aiMoveName = "coup"
        }
        
        return aiMoveName
    }
    
    override func getPlayerMove() -> Move {
        let moveName = getAIMoveName()
        
        //randomly select the target of the move
        var rand = Int.random(in: 0...players.count-1)
        var target = players[rand]
        
        if moveName == "steal" {
            while target.coins < 2 {
                rand = Int.random(in: 0...players.count-1)
                target = players[rand]
            }
        }
        
        if moveName == "income" || moveName == "foreignAid" || moveName == "tax" {
            return Move(name: moveName, caller: self, target: self)
        }
        
        return Move(name: moveName, caller: self, target: target)
    }
    
    // MARK: changeMoveRate
    // execute this function whenever this AI's turn begins
    func changeMoveRate() {
        
        // when the game is kicked off, and after this AI check out two cards
        let card1 = self.cards.0
        let card2 = self.cards.1
        var newRate = 0
        
        // 1. if AI has the move, increase the rate of it by 2
        //  if other players have the card, rating is increased by 0.5, each time
        // 2. if plyaer doe not have the move, decrease the rate of if by 1
        //  if any other player has the card, rating is lowered again by 1
        
        if card1.assassinate! || card2.assassinate! {
            
            // initialize it as 5
            moveRateDic.updateValue(5, forKey: "assassinate")
            
            newRate = moveRateDic["assassinate"]! + 10
            
            if card1.assassinate! && card2.assassinate! {
                newRate = moveRateDic["assassinate"]! + 20
            }
            
            moveRateDic.updateValue(newRate, forKey: "assassinate")
            
            for i in 0...players.count - 1 {
                let player = players[i]
                let pCard1 = player.cards.0
                let pCard2 = player.cards.1
                
                if player.name == self.name {
                    continue
                }
                
                if pCard1.revealed {
                    if pCard1.assassinate!{
                        newRate = moveRateDic["assassinate"]! + 10
                        moveRateDic.updateValue(newRate, forKey: "assassinate")
                    }
                }
                if pCard2.revealed {
                    if pCard2.assassinate!{
                        newRate = moveRateDic["assassinate"]! + 10
                        moveRateDic.updateValue(newRate, forKey: "assassinate")
                    }
                }
            }
            
            // if card1.revealed then they cannot use it
            if (card1.revealed && card1.assassinate!) || (card2.revealed && card2.assassinate!) {
                newRate = moveRateDic["assassinate"]! / 2
                
                for i in 0...players.count - 1 {
                    let player = players[i]
                    let pCard1 = player.cards.0
                    let pCard2 = player.cards.1
                    
                    if player.name == self.name {
                        continue
                    }
                    
                    if pCard1.revealed {
                        if pCard1.assassinate!{
                            newRate = moveRateDic["assassinate"]! / 2
                            moveRateDic.updateValue(newRate, forKey: "assassinate")
                        }
                    }
                    if pCard2.revealed {
                        if pCard2.assassinate!{
                            newRate = moveRateDic["assassinate"]! - 100
                            moveRateDic.updateValue(newRate, forKey: "assassinate")
                        }
                    }
                }
                
                moveRateDic.updateValue(newRate, forKey: "assassinate")
            }
            
        } else {
            newRate = moveRateDic["assassinate"]! - 1
            moveRateDic.updateValue(newRate, forKey: "assassinate")
            
            for i in 0...players.count - 1 {
                let player = players[i]
                let pCard1 = player.cards.0
                let pCard2 = player.cards.1
                
                if pCard1.revealed {
                    if pCard1.assassinate!{
                        newRate = moveRateDic["assassinate"]! - 2
                        moveRateDic.updateValue(newRate, forKey: "assassinate")
                    }
                }
                
                if pCard2.revealed {
                    if pCard2.assassinate!{
                        newRate = moveRateDic["assassinate"]! - 2
                        moveRateDic.updateValue(newRate, forKey: "assassinate")
                    }
                }
            }
        }
        
        if card1.exchange! || card2.exchange! {
            newRate = moveRateDic["exchange"]! + 10
            
            if card1.exchange! && card2.exchange! {
                newRate = moveRateDic["exchange"]! + 20
            }
            
            moveRateDic.updateValue(newRate, forKey: "exchange")
            
            for i in 0...players.count - 1 {
                let player = players[i]
                let pCard1 = player.cards.0
                let pCard2 = player.cards.1
                
                if player.name == self.name {
                    continue
                }
                
                if pCard1.revealed {
                    if pCard1.exchange!{
                        newRate = moveRateDic["exchange"]! + 10
                        moveRateDic.updateValue(newRate, forKey: "exchange")
                    }
                }
                
                if pCard2.revealed {
                    if pCard2.exchange!{
                        newRate = moveRateDic["exchange"]! + 10
                        moveRateDic.updateValue(newRate, forKey: "exchange")
                    }
                }
            }
            
            // if card1.revealed then they cannot use it
            if (card1.revealed && card1.exchange!) || (card2.revealed && card2.exchange!) {
                newRate = moveRateDic["exchange"]! / 2
                
                for i in 0...players.count - 1 {
                    let player = players[i]
                    let pCard1 = player.cards.0
                    let pCard2 = player.cards.1
                    
                    if player.name == self.name {
                        continue
                    }
                    
                    if pCard1.revealed {
                        if pCard1.exchange!{
                            newRate = moveRateDic["exchange"]! / 2
                            moveRateDic.updateValue(newRate, forKey: "exchange")
                        }
                    }
                    
                    if pCard2.revealed {
                        if pCard2.exchange!{
                            newRate = moveRateDic["exchange"]! - 100
                            moveRateDic.updateValue(newRate, forKey: "exchange")
                        }
                    }
                }
                
                moveRateDic.updateValue(newRate, forKey: "exchange")
            }
            
        } else {
            newRate = moveRateDic["exchange"]! - 1
            moveRateDic.updateValue(newRate, forKey: "exchange")
            
            for i in 0...players.count - 1 {
                let player = players[i]
                let pCard1 = player.cards.0
                let pCard2 = player.cards.1
                
                if pCard1.revealed {
                    if pCard1.exchange!{
                        newRate = moveRateDic["exchange"]! - 2
                        moveRateDic.updateValue(newRate, forKey: "exchange")
                    }
                }
                
                if pCard2.revealed {
                    if pCard2.exchange!{
                        newRate = moveRateDic["exchange"]! - 2
                        moveRateDic.updateValue(newRate, forKey: "exchange")
                    }
                }
            }
        }
        
        if card1.tax! || card2.tax! {
            newRate = moveRateDic["tax"]! + 10
            
            if card1.tax! && card2.tax! {
                newRate = moveRateDic["tax"]! + 20
            }
            
            moveRateDic.updateValue(newRate, forKey: "tax")
            
            for i in 0...players.count - 1 {
                let player = players[i]
                let pCard1 = player.cards.0
                let pCard2 = player.cards.1
                
                if player.name == self.name {
                    continue
                }
                
                if pCard1.revealed {
                    if pCard1.tax!{
                        newRate = moveRateDic["tax"]! + 10
                        moveRateDic.updateValue(newRate, forKey: "tax")
                    }
                }
                
                if pCard2.revealed {
                    if pCard2.tax!{
                        newRate = moveRateDic["tax"]! + 10
                        moveRateDic.updateValue(newRate, forKey: "tax")
                    }
                }
            }
            
            // if card1.revealed then they cannot use it
            if (card1.revealed && card1.tax!) || (card2.revealed && card2.tax!) {
                newRate = moveRateDic["tax"]! / 2
                
                for i in 0...players.count - 1 {
                    let player = players[i]
                    let pCard1 = player.cards.0
                    let pCard2 = player.cards.1
                    
                    if player.name == self.name {
                        continue
                    }
                    
                    if pCard1.revealed {
                        if pCard1.tax!{
                            newRate = moveRateDic["tax"]! / 2
                            moveRateDic.updateValue(newRate, forKey: "tax")
                        }
                    }
                    
                    if pCard2.revealed {
                        if pCard2.tax!{
                            newRate = moveRateDic["tax"]! - 100
                            moveRateDic.updateValue(newRate, forKey: "tax")
                        }
                    }
                }
                
                moveRateDic.updateValue(newRate, forKey: "tax")
            }
            
        } else {
            newRate = moveRateDic["tax"]! - 1
            moveRateDic.updateValue(newRate, forKey: "tax")
            
            for i in 0...players.count - 1 {
                let player = players[i]
                let pCard1 = player.cards.0
                let pCard2 = player.cards.1
                
                if pCard1.revealed {
                    if pCard1.tax!{
                        newRate = moveRateDic["tax"]! - 2
                        moveRateDic.updateValue(newRate, forKey: "tax")
                    }
                }
                
                if pCard2.revealed {
                    if pCard2.tax!{
                        newRate = moveRateDic["tax"]! - 2
                        moveRateDic.updateValue(newRate, forKey: "tax")
                    }
                }
            }
        }
        
        if card1.steal! || card2.steal! {
            
            //initialize it as 5
            moveRateDic.updateValue(5, forKey: "steal")
            
            newRate = moveRateDic["steal"]! + 10
            
            if card1.steal! && card2.steal! {
                newRate = moveRateDic["steal"]! + 20
            }
            
            moveRateDic.updateValue(newRate, forKey: "steal")
            
            for i in 0...players.count - 1 {
                let player = players[i]
                let pCard1 = player.cards.0
                let pCard2 = player.cards.1
                
                if player.name == self.name {
                    continue
                }
                
                if pCard1.revealed {
                    if pCard1.steal!{
                        newRate = moveRateDic["steal"]! + 10
                        moveRateDic.updateValue(newRate, forKey: "steal")
                    }
                }
                
                if pCard2.revealed {
                    if pCard2.steal!{
                        newRate = moveRateDic["steal"]! + 10
                        moveRateDic.updateValue(newRate, forKey: "steal")
                    }
                }
            }
            
            // if card1.revealed then they cannot use it
            if (card1.revealed && card1.steal!) || (card2.revealed && card2.steal!) {
                newRate = moveRateDic["steal"]! / 2
                
                for i in 0...players.count - 1 {
                    let player = players[i]
                    let pCard1 = player.cards.0
                    let pCard2 = player.cards.1
                    
                    if player.name == self.name {
                        continue
                    }
                    
                    if pCard1.revealed {
                        if pCard1.steal!{
                            newRate = moveRateDic["steal"]! / 2
                            moveRateDic.updateValue(newRate, forKey: "steal")
                        }
                    }
                    
                    if pCard2.revealed {
                        if pCard2.steal!{
                            newRate = moveRateDic["steal"]! - 100
                            moveRateDic.updateValue(newRate, forKey: "steal")
                        }
                    }
                }
                
                moveRateDic.updateValue(newRate, forKey: "steal")
            }
            
        } else {
            newRate = moveRateDic["steal"]! - 1
            moveRateDic.updateValue(newRate, forKey: "steal")
            
            for i in 0...players.count - 1 {
                let player = players[i]
                let pCard1 = player.cards.0
                let pCard2 = player.cards.1
                
                if pCard1.revealed {
                    if pCard1.steal!{
                        newRate = moveRateDic["steal"]! - 2
                        moveRateDic.updateValue(newRate, forKey: "steal")
                    }
                }
                
                if pCard2.revealed {
                    if pCard2.steal!{
                        newRate = moveRateDic["steal"]! - 2
                        moveRateDic.updateValue(newRate, forKey: "steal")
                    }
                }
            }
        }
        
        if card1.foreignAid! || card2.foreignAid! {
            newRate = moveRateDic["foreignAid"]! + 10
            
            if card1.foreignAid! && card2.foreignAid! {
                newRate = moveRateDic["foreignAid"]! + 20
            }
            
            moveRateDic.updateValue(newRate, forKey: "foreignAid")
            
            for i in 0...players.count - 1 {
                let player = players[i]
                let pCard1 = player.cards.0
                let pCard2 = player.cards.1
                
                if player.name == self.name {
                    continue
                }
                
                if pCard1.revealed {
                    if pCard1.foreignAid!{
                        newRate = moveRateDic["foreignAid"]! + 10
                        moveRateDic.updateValue(newRate, forKey: "foreignAid")
                    }
                }
                
                if pCard2.revealed {
                    if pCard2.foreignAid!{
                        newRate = moveRateDic["foreignAid"]! + 10
                        moveRateDic.updateValue(newRate, forKey: "foreignAid")
                    }
                }
            }
            
            // if card1.revealed then they cannot use it
            if (card1.revealed && card1.foreignAid!) || (card2.revealed && card2.foreignAid!) {
                newRate = moveRateDic["foreignAid"]! / 2
                
                for i in 0...players.count - 1 {
                    let player = players[i]
                    let pCard1 = player.cards.0
                    let pCard2 = player.cards.1
                    
                    if player.name == self.name {
                        continue
                    }
                    
                    if pCard1.revealed {
                        if pCard1.foreignAid!{
                            newRate = moveRateDic["foreignAid"]! / 2
                            moveRateDic.updateValue(newRate, forKey: "foreignAid")
                        }
                    }
                    
                    if pCard2.revealed {
                        if pCard2.foreignAid!{
                            newRate = moveRateDic["foreignAid"]! - 100
                            moveRateDic.updateValue(newRate, forKey: "foreignAid")
                        }
                    }
                }
                
                moveRateDic.updateValue(newRate, forKey: "foreignAid")
            }
            
        } else {
            newRate = moveRateDic["foreignAid"]! - 1
            moveRateDic.updateValue(newRate, forKey: "foreignAid")
            
            for i in 0...players.count - 1 {
                let player = players[i]
                let pCard1 = player.cards.0
                let pCard2 = player.cards.1
                
                if pCard1.revealed {
                    if pCard1.foreignAid!{
                        newRate = moveRateDic["foreignAid"]! - 2
                        moveRateDic.updateValue(newRate, forKey: "foreignAid")
                    }
                }
                
                if pCard2.revealed {
                    if pCard2.foreignAid!{
                        newRate = moveRateDic["foreignAid"]! - 2
                        moveRateDic.updateValue(newRate, forKey: "foreignAid")
                    }
                }
            }
        }
        
        // Adjusting rate based on Money
        if self.coins < 3 {
            newRate = moveRateDic["income"]! + 10
            moveRateDic.updateValue(newRate, forKey: "income")
            
            moveRateDic.updateValue(0, forKey: "assassinate")
            
        } else {
            newRate = moveRateDic["income"]! - 10
            moveRateDic.updateValue(newRate, forKey: "income")
        }
        
        // Adjustig rate of steal based on Money
        var count = 0
        
        for i in 0...players.count - 1 {
            let player = players[i]
            
            if player.name == self.name {
                continue
            }
            
            if player.coins < 2 {
                count += 1
            }
        }
        
        if count == players.count - 1 {
            moveRateDic.updateValue(0, forKey: "steal")
        }
        
        // 0 filter
        if moveRateDic["income"]! < 0 {
            moveRateDic.updateValue(0, forKey: "income")
        }
        
        if moveRateDic["foreignAid"]! < 0 {
            moveRateDic.updateValue(0, forKey: "foreignAid")
        }
        
        if moveRateDic["tax"]! < 0 {
            moveRateDic.updateValue(0, forKey: "tax")
        }
        
        if moveRateDic["steal"]! < 0 {
            moveRateDic.updateValue(0, forKey: "steal")
        }
        
        if moveRateDic["assassinate"]! < 0 {
            moveRateDic.updateValue(0, forKey: "assassinate")
        }
        
        if moveRateDic["exchange"]! < 0 {
            moveRateDic.updateValue(0, forKey: "exchange")
        }
        
    }

    // MARK:- changeBlockRate
    /*
    You can find out these variables in Card.swift under the Card class and the children classes of Card
        var blockAssassination = true -> Contessa
        var blockForeignAid = true -> Duke
        var blockSteal = true -> Captain and Ambassador
     
    */
        
    // MARK:- adustChallengeRate
    // allow/challenge
    // other card count is 1, then 80/20
    // other card count is 2, then 75/25
    // other card count is 3, then 0/100
    func adjustChallengeRate() {
        
        let card1 = self.cards.0
        let card2 = self.cards.1
        
        var assassinateCount = 0
        var exchangeCount = 0
        var taxCount = 0
        var stealCount = 0
        
        if moveLog[moveLog.count-1].name == "assassinate" {
            if card1.assassinate! || card2.assassinate! {
                assassinateCount += 1
                
                if card1.assassinate! && card2.assassinate! {
                    assassinateCount += 1
                }
                
                for i in 0...players.count - 1 {
                    let player = players[i]
                    let pCard1 = player.cards.0
                    let pCard2 = player.cards.1
                    
                    if pCard1.revealed {
                        if pCard1.assassinate!{
                            assassinateCount += 1
                        }
                    }
                    
                    if pCard2.revealed {
                        if pCard2.assassinate!{
                            assassinateCount += 1
                        }
                    }
                }
            }
        }
        
        if moveLog[moveLog.count-1].name == "exchange" {
            if card1.exchange! || card2.exchange! {
                exchangeCount += 1
                
                if card1.exchange! && card2.exchange! {
                    exchangeCount += 1
                }
                
                for i in 0...players.count - 1 {
                    let player = players[i]
                    let pCard1 = player.cards.0
                    let pCard2 = player.cards.1
                    
                    if pCard1.revealed {
                        if pCard1.exchange!{
                            exchangeCount += 1
                        }
                    }
                    
                    if pCard2.revealed {
                        if pCard2.exchange!{
                            exchangeCount += 1
                        }
                    }
                }
            }
        }
        
        if moveLog[moveLog.count-1].name == "tax" {
            if card1.tax! || card2.tax! {
                taxCount += 1
                
                if card1.tax! && card2.tax! {
                    taxCount += 1
                }
                
                for i in 0...players.count - 1 {
                    let player = players[i]
                    let pCard1 = player.cards.0
                    let pCard2 = player.cards.1
                    
                    if pCard1.revealed {
                        if pCard1.tax!{
                            taxCount += 1
                        }
                    }
                    
                    if pCard2.revealed {
                        if pCard2.tax!{
                            taxCount += 1
                        }
                    }
                }
            }
        }
        
        if moveLog[moveLog.count-1].name == "steal" {
            if card1.steal! || card2.steal! {
                stealCount += 1
                
                if card1.steal! && card2.steal! {
                    stealCount += 1
                }
                
                for i in 0...players.count - 1 {
                    let player = players[i]
                    let pCard1 = player.cards.0
                    let pCard2 = player.cards.1
                    
                    if pCard1.revealed {
                        if pCard1.steal!{
                            stealCount += 1
                        }
                    }
                    
                    if pCard2.revealed {
                        if pCard2.steal!{
                            stealCount += 1
                        }
                    }
                }
            }
        }
        
        //access move logs most recent move
        if assassinateCount <= 1 || exchangeCount <= 1 || taxCount <= 1 || stealCount <= 1 {
            challengeRate = 0.30
        } else if assassinateCount == 2 || exchangeCount == 2 || taxCount == 2 || stealCount == 2 {
            challengeRate = 0.45
        } else if assassinateCount >= 3 || exchangeCount >= 3 || taxCount >= 3 || stealCount >= 3 {
            challengeRate = 1.00
        } else {
            print("challengeRate = 0.00")
        }
        
    }

    // MARK: - getChallengeOrAllow
    // -> challenge or allow to the latest move from moveLog
    //   based on the percentage of challenge rate.
    override func getChallengeOrAllow(target: Player) -> Move {
        //exclude all the moves except for challenge or allow
        self.adjustChallengeRate()
        
        let rand = Double.random(in: 0.01...1.00)
        
        print(challengeRate)
        print(rand)
        
        if rand <= challengeRate {
            return Move(name: "challenge", caller: self, target: target)
        }
        
        return Move(name:"allow", caller: self, target: target)
    }
}
