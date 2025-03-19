class Undo {
    
    // GameScene vars
    var choice: Int
    var turn: Int
    var gameOver: Bool
    
    // Game vars
    var winner: Int
    var board: [[Piece]]
    var players: [Player]
    var tie: Bool
    var choosingThree: Bool
    var gotEight: Bool
    var feed: String
    var gk: Int
    var gc: Int
    var ok: Int
    var oc: Int
    
    init() {
        self.choice = 1
        self.turn = 0
        self.gameOver = false
        
        self.winner = -1
        self.board = (0..<6).map { _ in (0..<6).map { _ in Piece() } }
        self.players = (0..<2).map { _ in Player() }
        self.tie = false
        self.choosingThree = false
        self.gotEight = false
        self.feed = ""
        self.gk = 8
        self.gc = 0
        self.ok = 8
        self.oc = 0
    }
    
    func printGame() {

        print()

        if 6 > 9 {
            print(" ", terminator: "")
        }

        for i in 1...6 {
            if i > 10 {
                print(" \(i)", terminator: "")
            } else {
                print("  \(i)", terminator: "")
            }
        }
        print()

        for i in 0..<6 {
            if 6 > 9 {
                if (i + 1) < 10 {
                    print("\(i + 1)  ", terminator: "")
                } else {
                    print("\(i + 1) ", terminator: "")
                }
            } else {
                print("\(i + 1) ", terminator: "")
            }

            for j in 0..<6 {
                if board[i][j].getPlayer() == -1 {
                    print("-", terminator: "")
                    if j != (6 - 1) {
                        print("  ", terminator: "")
                    }
                } else {
                    print("\(board[i][j].getPlayer() + 1)", terminator: "")
                    if board[i][j].getType() == 1 {
                        print("K", terminator: "")
                    } else if board[i][j].getType() == 2 {
                        print("C", terminator: "")
                    }
                    if j != (6 - 1) {
                        print(" ", terminator: "")
                    }
                }
            }
            
            print()
            print()
        }

        for i in 0..<2 {
            print("Player \(i + 1): Kitten = \(players[i].getKittens()) Cat = \(players[i].getCats())")
        }
        print()

    }
}
