class Move{
    var moveName: String
    var callerPlayer: String
    var targetPlayer: String
    
    init(move: String, caller: String, target: String) {
        moveName = move
        callerPlayer = caller
        targetPlayer = target
    }
}
