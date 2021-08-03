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
}
