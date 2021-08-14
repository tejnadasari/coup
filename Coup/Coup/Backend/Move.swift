class Move {
    
    var name: String
    var caller: Player
    var target: Player
    
    init() {
        name = ""
        caller = Player()
        target = Player()
    }
    
    init(name: String, caller: Player, target: Player) {
        self.name = name
        self.caller = caller
        self.target = target
    }
    
    //check whenever player is real LoginViewController.getUsername()
    func toString() -> String {
        if (self.name == "income") {
            return "\(self.caller.name) claimed income. \nCannot challenge."
        }
        else if (self.name == "foreignAid") {
            return "\(self.caller.name) is claiming foreign aid. \nWaiting for challenges."
        }
        else if (self.name == "tax") {
            return "\(self.caller.name) is claiming tax. \nWaiting for challenges."
        }
        else if (self.name == "coup") {
            return "\(self.caller.name) played coup towards \(self.target.name). \nCannot challenge."
        }
        else if (self.name == "steal") {
            return "\(self.caller.name) is trying to steal $2\n from \(self.target.name).\n Waiting for challenges."
        }
        else if (self.name == "exchange") {
            return "\(self.caller.name) is trying to exchange.\n Waiting for challenges."
        }
        return "\(self.caller.name) played \(self.name) towards \(self.target.name).\n Waiting for challenges."
    }
    
    func successfulString() -> String {
        if (self.name == "foreignAid") {
            return "\(self.caller.name) successfully played\n the move foreign aid."
        }
        return "\(self.caller.name) successfully played\n the move \(self.name)."
    }
    
    func challengeString() -> String {
        return "\(self.caller.name) challenges \(self.target.name)."
    }
    
    func challengeFailedString() -> String {
        return "\(self.caller.name) incorrectly challenged \(self.target.name),\n and reveals: "
    }
}
