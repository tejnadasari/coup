class Move {
    var name: String
    var caller: Player
    var target: Player

    init(){
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
        return "\(self.caller.name) played the move \(self.name) onto \(self.target.name). Waiting for any challenges."
    }
    
    func successfulString() -> String{
        return "\(self.caller.name) successfully played the move \(self.name)."
    }
    
    func challengeString() -> String{
        return "\(self.caller.name) challenges \(self.target.name)."
    }
    
    func challengeFailedString() -> String{
        return "\(self.caller.name) incorrectly challenged \(self.target.name), he reveals: "
    }
}
