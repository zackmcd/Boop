class Piece {
    private var type: Int  // 1 = kitten, 2 = cat
    private var player: Int  // 0-n depending on how many players
    
    // Default initializer
    init() {
        self.type = 0
        self.player = -1
    }
    
    // Parameterized initializer
    init(type: Int, player: Int) {
        self.type = type
        self.player = player
    }
    
    // Assignment operator equivalent (copying properties)
    func copy(piece: Piece) {
        self.type = piece.type
        self.player = piece.player
    }
    
    // Method to reset piece
    func remove() {
        self.type = 0
        self.player = -1
    }
    
    // Setter for type
    func setType(t: Int) {
        self.type = t
    }
    
    // Setter for player
    func setPlayer(p: Int) {
        self.player = p
    }
    
    // Getter for type
    func getType() -> Int {
        return type
    }
    
    // Getter for player
    func getPlayer() -> Int {
        return player
    }
}
