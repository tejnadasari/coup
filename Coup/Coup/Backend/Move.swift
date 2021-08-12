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
        if (self.name == "income"){
            return "\(self.caller.name) claimed income. Cannot challenge."
        }
        else if (self.name == "foreignAid" || self.name == "tax"){
            return "\(self.caller.name) is claiming foreign aid. Waiting for challenges."
        }
        else if (self.name == "tax"){
            return "\(self.caller.name) is claiming tax. Waiting for challenges."
        }
        else if (self.name == "coup"){
            return "\(self.caller.name) played coup towards \(self.target.name). Cannot challenge."
        }
        else if (self.name == "steal"){
            return "\(self.caller.name) is trying to steal $2 from \(self.target.name). Waiting for challenges."
        }
        else if (self.name == "exchange"){
            return "\(self.caller.name) is trying to exchange. Waiting for challenges."
        }
        return "\(self.caller.name) played \(self.name) towards \(self.target.name). Waiting for challenges."
    }
    
    func successfulString() -> String{
        return "\(self.caller.name) successfully played the move \(self.name)."
    }
    
    func challengeString() -> String{
        return "\(self.caller.name) challenges \(self.target.name)."
    }
    
    func challengeFailedString() -> String{
        return "\(self.caller.name) incorrectly challenged \(self.target.name), and reveals: "
    }
}
