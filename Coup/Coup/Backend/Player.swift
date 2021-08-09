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
    
    func isPlayerRevealed() -> Bool{
            return (self.cards.0.revealed && self.cards.1.revealed)
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
    
    var moveRateDic: [String:Double] = ["income":2.0, "foreignAid":5.0, "tax":5.0, "steal":5.0, "assassinate":5.0, "exchange":5.0, "coup":5.0]
    
    var blockRateDic: [String:Double] = ["blockAssassination":5.0, "blockForeignAid":5.0, "blockSteal":5.0]
    
    var challengeRate = 0.15

    // MARK:- getAIMoveName and getPlayerMove
    
    // Let's get the name of Move first and then, let's figure out the target
    func getAIMoveName() -> String {
        //exclude the moves challenge / allow
        //changeMoverate(), then loop through dictionary to find move with highest rating
        changeMoveRate()
        
        var aiMoveName = ""
        var maxDouble = -1.0
        
        for (key, value) in moveRateDic {
            if value >= maxDouble {
                maxDouble = value
                aiMoveName = key
            }
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
        let rand = Int.random(in: 0...players.count-1)
        let target = players[rand]
        
        return Move(name: moveName, caller: self, target: target)
    }
    
    // MARK: changeMoveRate
    // execute this function whenever this AI's turn begins
    func changeMoveRate() {
        
        // when the game is kicked off, and after this AI check out two cards
        let card1 = self.cards.0
        let card2 = self.cards.1
        var newRate = 0.0
        
        
        // 1. if AI has the move, increase the rate of it by 2
        //  if other players have the card, rating is increased by 0.5, each time
        // 2. if plyaer doe not have the move, decrease the rate of if by 1
        //  if any other player has the card, rating is lowered again by 1
        
        if card1.assassinate! || card2.assassinate! {
            
            newRate = moveRateDic["assassinate"]! + 2
            
            if card1.assassinate! && card2.assassinate! {
                newRate = moveRateDic["assassinate"]! + 4
            }
            
            moveRateDic.updateValue(newRate, forKey: "assassinate")
            
            for i in 0...players.count - 1 {
                let player = players[i]
                let pCard1 = player.cards.0
                let pCard2 = player.cards.1
                
                if pCard1.revealed {
                    if pCard1.assassinate!{
                        newRate = moveRateDic["assassinate"]! + 0.5
                        moveRateDic.updateValue(newRate, forKey: "assassinate")
                    }
                }
                if pCard2.revealed {
                    if pCard2.assassinate!{
                        newRate = moveRateDic["assassinate"]! + 0.5
                        moveRateDic.updateValue(newRate, forKey: "assassinate")
                    }
                }
            }
            
            // if card1.revealed then they cannot use it
            if (card1.revealed && card1.assassinate!) || (card2.revealed && card2.assassinate!) {
                newRate = moveRateDic["assassinate"]! - 2
                
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
                        newRate = moveRateDic["assassinate"]! - 1
                        moveRateDic.updateValue(newRate, forKey: "assassinate")
                    }
                }
                
                if pCard2.revealed {
                    if pCard2.assassinate!{
                        newRate = moveRateDic["assassinate"]! - 1
                        moveRateDic.updateValue(newRate, forKey: "assassinate")
                    }
                }
            }
        }
        
        if card1.exchange! || card2.exchange! {
            newRate = moveRateDic["exchange"]! + 2
            
            if card1.exchange! && card2.exchange! {
                newRate = moveRateDic["exchange"]! + 4
            }
            
            moveRateDic.updateValue(newRate, forKey: "exchange")
            
            for i in 0...players.count - 1 {
                let player = players[i]
                let pCard1 = player.cards.0
                let pCard2 = player.cards.1
                
                if pCard1.revealed {
                    if pCard1.exchange!{
                        newRate = moveRateDic["exchange"]! + 0.5
                        moveRateDic.updateValue(newRate, forKey: "exchange")
                    }
                }
                
                if pCard2.revealed {
                    if pCard2.exchange!{
                        newRate = moveRateDic["exchange"]! + 0.5
                        moveRateDic.updateValue(newRate, forKey: "exchange")
                    }
                }
            }
            
            // if card1.revealed then they cannot use it
            if (card1.revealed && card1.exchange!) || (card2.revealed && card2.exchange!) {
                newRate = moveRateDic["exchange"]! - 2
                
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
                        newRate = moveRateDic["exchange"]! - 1
                        moveRateDic.updateValue(newRate, forKey: "exchange")
                    }
                }
                
                if pCard2.revealed {
                    if pCard2.exchange!{
                        newRate = moveRateDic["exchange"]! - 1
                        moveRateDic.updateValue(newRate, forKey: "exchange")
                    }
                }
            }
        }
        
        if card1.tax! || card2.tax! {
            newRate = moveRateDic["tax"]! + 2
            
            if card1.tax! && card2.tax! {
                newRate = moveRateDic["tax"]! + 4
            }
            
            moveRateDic.updateValue(newRate, forKey: "tax")
            
            for i in 0...players.count - 1 {
                let player = players[i]
                let pCard1 = player.cards.0
                let pCard2 = player.cards.1
                
                if pCard1.revealed {
                    if pCard1.tax!{
                        newRate = moveRateDic["tax"]! + 0.5
                        moveRateDic.updateValue(newRate, forKey: "tax")
                    }
                }
                
                if pCard2.revealed {
                    if pCard2.tax!{
                        newRate = moveRateDic["tax"]! + 0.5
                        moveRateDic.updateValue(newRate, forKey: "tax")
                    }
                }
            }
            
            // if card1.revealed then they cannot use it
            if (card1.revealed && card1.tax!) || (card2.revealed && card2.tax!) {
                newRate = moveRateDic["tax"]! - 2
                
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
                        newRate = moveRateDic["tax"]! - 1
                        moveRateDic.updateValue(newRate, forKey: "tax")
                    }
                }
                
                if pCard2.revealed {
                    if pCard2.tax!{
                        newRate = moveRateDic["tax"]! - 1
                        moveRateDic.updateValue(newRate, forKey: "tax")
                    }
                }
            }
        }
        
        if card1.steal! || card2.steal! {
            newRate = moveRateDic["steal"]! + 2
            
            if card1.steal! && card2.steal! {
                newRate = moveRateDic["steal"]! + 4
            }
            
            moveRateDic.updateValue(newRate, forKey: "steal")
            
            for i in 0...players.count - 1 {
                let player = players[i]
                let pCard1 = player.cards.0
                let pCard2 = player.cards.1
                
                if pCard1.revealed {
                    if pCard1.steal!{
                        newRate = moveRateDic["steal"]! + 0.5
                        moveRateDic.updateValue(newRate, forKey: "steal")
                    }
                }
                
                if pCard2.revealed {
                    if pCard2.steal!{
                        newRate = moveRateDic["steal"]! + 0.5
                        moveRateDic.updateValue(newRate, forKey: "steal")
                    }
                }
            }
            
            // if card1.revealed then they cannot use it
            if (card1.revealed && card1.steal!) || (card2.revealed && card2.steal!) {
                newRate = moveRateDic["steal"]! - 2
                
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
                        newRate = moveRateDic["steal"]! - 1
                        moveRateDic.updateValue(newRate, forKey: "steal")
                    }
                }
                
                if pCard2.revealed {
                    if pCard2.steal!{
                        newRate = moveRateDic["steal"]! - 1
                        moveRateDic.updateValue(newRate, forKey: "steal")
                    }
                }
            }
        }
        
        // Adjusting rate according to Money
        if self.coins < 3 {
            newRate = moveRateDic["income"]! + 2
            moveRateDic.updateValue(newRate, forKey: "income")
            
            newRate = moveRateDic["foreignAid"]! + 2
            moveRateDic.updateValue(newRate, forKey: "foreignAid")
            
            newRate = moveRateDic["tax"]! + 2
            moveRateDic.updateValue(newRate, forKey: "tax")
        } else {
            newRate = moveRateDic["steal"]! + 2
            moveRateDic.updateValue(newRate, forKey: "steal")
            
            newRate = moveRateDic["assassinate"]! + 2
            moveRateDic.updateValue(newRate, forKey: "assassinate")
        }
        
    }

    // MARK:- changeBlockRate
    /*
    You can find out these variables in Card.swift under the Card class and the children classes of Card
        var blockAssassination = true -> Contessa
        var blockForeignAid = true -> Duke
        var blockSteal = true -> Captain and Ambassador
     
    */
    func changeBlockRate() {
        // when the game is kicked off, and after this AI check out two cards
        let card1 = self.cards.0
        let card2 = self.cards.1
        var newRate = 0.0
        
        // same principles as changeMoveRate()
        if card1.blockAssassination || card2.blockAssassination {
            
            newRate = blockRateDic["blockAssassination"]! + 2
            
            if card1.blockAssassination && card2.blockAssassination {
                newRate = blockRateDic["blockAssassination"]! + 4
            }
            
            blockRateDic.updateValue(newRate, forKey: "blockAssassination")
            
            for i in 0...players.count - 1 {
                let player = players[i]
                let pCard1 = player.cards.0
                let pCard2 = player.cards.1
                
                if pCard1.revealed {
                    if pCard1.blockAssassination{
                        newRate = blockRateDic["blockAssassination"]! + 0.5
                        blockRateDic.updateValue(newRate, forKey: "blockAssassination")
                    }
                }
                if pCard2.revealed {
                    if pCard2.blockAssassination{
                        newRate = blockRateDic["blockAssassination"]! + 0.5
                        blockRateDic.updateValue(newRate, forKey: "blockAssassination")
                    }
                }
            }
            
            // if card1.revealed then they cannot use it
            if card1.revealed || card2.revealed {
                newRate = blockRateDic["blockAssassination"]! - 2
                
                if card1.revealed && card2.revealed {
                    newRate = blockRateDic["blockAssassination"]! - 4
                }
                
                blockRateDic.updateValue(newRate, forKey: "blockAssassination")
            }
            
        } else {
            newRate = blockRateDic["blockAssassination"]! - 1
            blockRateDic.updateValue(newRate, forKey: "blockAssassination")
            
            for i in 0...players.count - 1 {
                let player = players[i]
                let pCard1 = player.cards.0
                let pCard2 = player.cards.1
                
                if pCard1.revealed {
                    if pCard1.blockAssassination{
                        newRate = blockRateDic["blockAssassination"]! - 1
                        blockRateDic.updateValue(newRate, forKey: "blockAssassination")
                    }
                }
                
                if pCard2.revealed {
                    if pCard2.blockAssassination{
                        newRate = blockRateDic["blockAssassination"]! - 1
                        blockRateDic.updateValue(newRate, forKey: "blockAssassination")
                    }
                }
            }
        }
        
        if card1.blockForeignAid || card2.blockForeignAid {
            
            newRate = blockRateDic["blockForeignAid"]! + 2
            
            if card1.blockForeignAid && card2.blockForeignAid {
                newRate = blockRateDic["blockForeignAid"]! + 4
            }
            
            blockRateDic.updateValue(newRate, forKey: "blockForeignAid")
            
            for i in 0...players.count - 1 {
                let player = players[i]
                let pCard1 = player.cards.0
                let pCard2 = player.cards.1
                
                if pCard1.revealed {
                    if pCard1.blockForeignAid{
                        newRate = blockRateDic["blockForeignAid"]! + 0.5
                        blockRateDic.updateValue(newRate, forKey: "blockForeignAid")
                    }
                }
                if pCard2.revealed {
                    if pCard2.blockForeignAid{
                        newRate = blockRateDic["blockForeignAid"]! + 0.5
                        blockRateDic.updateValue(newRate, forKey: "blockForeignAid")
                    }
                }
            }
            
            // if card1.revealed then they cannot use it
            if card1.revealed || card2.revealed {
                newRate = blockRateDic["blockForeignAid"]! - 2
                
                if card1.revealed && card2.revealed {
                    newRate = blockRateDic["blockForeignAid"]! - 4
                }
                
                blockRateDic.updateValue(newRate, forKey: "blockForeignAid")
            }
            
        } else {
            newRate = blockRateDic["blockForeignAid"]! - 1
            blockRateDic.updateValue(newRate, forKey: "blockForeignAid")
            
            for i in 0...players.count - 1 {
                let player = players[i]
                let pCard1 = player.cards.0
                let pCard2 = player.cards.1
                
                if pCard1.revealed {
                    if pCard1.blockForeignAid{
                        newRate = blockRateDic["blockForeignAid"]! - 1
                        blockRateDic.updateValue(newRate, forKey: "blockForeignAid")
                    }
                }
                
                if pCard2.revealed {
                    if pCard2.blockForeignAid{
                        newRate = blockRateDic["blockForeignAid"]! - 1
                        blockRateDic.updateValue(newRate, forKey: "blockForeignAid")
                    }
                }
            }
        }
        
        if card1.blockSteal || card2.blockSteal {
            
            newRate = blockRateDic["blockSteal"]! + 2
            
            if card1.blockSteal && card2.blockSteal {
                newRate = blockRateDic["blockSteal"]! + 4
            }
            
            blockRateDic.updateValue(newRate, forKey: "blockSteal")
            
            for i in 0...players.count - 1 {
                let player = players[i]
                let pCard1 = player.cards.0
                let pCard2 = player.cards.1
                
                if pCard1.revealed {
                    if pCard1.blockSteal{
                        newRate = blockRateDic["blockSteal"]! + 0.5
                        blockRateDic.updateValue(newRate, forKey: "blockSteal")
                    }
                }
                if pCard2.revealed {
                    if pCard2.blockSteal{
                        newRate = blockRateDic["blockSteal"]! + 0.5
                        blockRateDic.updateValue(newRate, forKey: "blockSteal")
                    }
                }
            }
            
            // if card1.revealed then they cannot use it
            if card1.revealed || card2.revealed {
                newRate = blockRateDic["blockSteal"]! - 2
                
                if card1.revealed && card2.revealed {
                    newRate = blockRateDic["blockSteal"]! - 4
                }
                
                blockRateDic.updateValue(newRate, forKey: "blockSteal")
            }
            
        } else {
            newRate = blockRateDic["blockSteal"]! - 1
            blockRateDic.updateValue(newRate, forKey: "blockSteal")
            
            for i in 0...players.count - 1 {
                let player = players[i]
                let pCard1 = player.cards.0
                let pCard2 = player.cards.1
                
                if pCard1.revealed {
                    if pCard1.blockSteal{
                        newRate = blockRateDic["blockSteal"]! - 1
                        blockRateDic.updateValue(newRate, forKey: "blockSteal")
                    }
                }
                
                if pCard2.revealed {
                    if pCard2.blockSteal{
                        newRate = blockRateDic["blockSteal"]! - 1
                        blockRateDic.updateValue(newRate, forKey: "blockSteal")
                    }
                }
            }
        }
        
    }
    
    // MARK: blockOrNot
    // blockOrNot()
    // -> determine if the AI will block against the latest move from moveLog
    //    based on the probability using each block~ rate
    func blockOrNot() -> Bool{
        changeBlockRate()
        
        var block = false
        
        if moveLog[moveLog.count - 1].name == "assassinate" {
            let rate = blockRateDic["blockAssassination"]!
            
            if rate >= 10.0 {
                block = true
            } else {
                let rand = Double.random(in: 0.0...10.0)
                
                if rand <= rate {
                    block = true
                }
            }
            
        } else if moveLog[moveLog.count - 1].name == "foreignAid" {
            let rate = blockRateDic["blockForeignAid"]!
            
            if rate >= 10.0 {
                block = true
            } else {
                let rand = Double.random(in: 0.0...10.0)
                
                if rand <= rate {
                    block = true
                }
            }
            
        } else if moveLog[moveLog.count - 1].name == "steal" {
            let rate = blockRateDic["blockSteal"]!
            
            if rate >= 10.0 {
                block = true
            } else {
                let rand = Double.random(in: 0.0...10.0)
                
                if rand <= rate {
                    block = true
                }
            }
            
        } else {
            print("Not Applicable")
        }
        
        return block
    }
        
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
        if assassinateCount == 1 || exchangeCount == 1 || taxCount == 1 || stealCount == 1 {
            challengeRate = 0.20
        } else if assassinateCount == 2 || exchangeCount == 2 || taxCount == 2 || stealCount == 2 {
            challengeRate = 0.25
        } else if assassinateCount >= 3 || exchangeCount >= 3 || taxCount >= 3 || stealCount >= 3 {
            challengeRate = 1.00
        } else {
            print("Not Applicable")
        }
        
    }

    // MARK: getChallengeOrAllow
    // -> challenge or allow to the latest move from moveLog
    //   based on the percentage of challenge rate.
    override func getChallengeOrAllow(target: Player) -> Move {
        //exclude all the moves except for challenge or allow
        self.adjustChallengeRate()
        
        let rand = Double.random(in: 0...1.00)
        
        if rand <= challengeRate {
            return Move(name: "challenge", caller: self, target: target)
        }
        
        return Move(name:"allow", caller: self, target: target)
    }
}
