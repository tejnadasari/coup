import UIKit

class Card {
    
    var name: String?
    var photo: UIImage?
    var tax: Bool?
    var assassinate: Bool?
    var exchange: Bool?
    var steal: Bool?
    var foreignAid : Bool?
    var coup: Bool?
    var blockAssassination = false
    var blockForeignAid = false
    var blockSteal = false
    var revealed: Bool!
    
    init() {
    }
    
    init(name: String) {
    }
}

class Assassin: Card {
    override init() {
        super.init()
        name = "Assassin"
        photo = UIImage(named: "Assassin.jpeg")
        tax = false
        assassinate = true
        exchange = false
        steal = false
        foreignAid = false
        coup = true
        revealed = false
    }
}

class Ambassador: Card {
    override init() {
        super.init()
        name = "Ambassador"
        photo = UIImage(named: "Ambassador.jpeg")
        tax = false
        assassinate = false
        exchange = true
        steal = false
        foreignAid = false
        blockSteal = true
        coup = true
        revealed = false
    }
}

class Captain: Card {
    override init() {
        super.init()
        name = "Captain"
        photo = UIImage(named: "Captain.jpeg")
        tax = false
        assassinate = false
        exchange = false
        steal = true
        foreignAid = false
        blockSteal = true
        coup = true
        revealed = false
    }
}

class Contessa: Card {
    override init() {
        super.init()
        name = "Contessa"
        photo = UIImage(named: "Contessa.jpeg")
        tax = false
        assassinate = false
        exchange = false
        steal = false
        foreignAid = true
        blockAssassination = true
        coup = true
        revealed = false
    }
}

class Duke: Card {
    override init() {
        super.init()
        name = "Duke"
        photo = UIImage(named: "Duke.jpeg")
        tax = true
        assassinate = false
        exchange = false
        steal = false
        foreignAid = false
        blockForeignAid = true
        coup = true
        revealed = false
    }
}
