import Foundation

class Game : NSObject {
    
    private var size: Int
    private var numPlayers: Int
    private var winner: Int
    var board: [[Piece]]
    var players: [Player]
    var threes: [[Int]]
    var numThrees: Int
    private var tie: Bool
    
    private var choosingThree: Bool
    private var gotEight: Bool
    @objc dynamic var feedCount: Int
    private var feed: String
    @objc dynamic var gk: Int
    @objc dynamic var gc: Int
    @objc dynamic var ok: Int
    @objc dynamic var oc: Int
    
    var boopChanges: [[Int]] // player, type, row, col, action
    var boopCount: Int
    
    var choosingIndices: [[Int]] // player, start, end, not sharing 3 in a row position in threes
    var sharingPoints: [[Int]]
    var sharingCountG: Int
    var sharingCountO: Int

    override init() {
        self.size = 0
        self.numPlayers = 0
        self.winner = -1
        self.board = []
        self.players = []
        self.threes = []
        self.numThrees = 0
        self.tie = false
        self.choosingThree = false
        self.gotEight = false
        self.feedCount = 0
        self.feed = ""
        self.gk = 8
        self.gc = 0
        self.ok = 8
        self.oc = 0
        self.boopChanges = []
        self.boopCount = 0
        self.choosingIndices = []
        self.sharingPoints = []
        self.sharingCountG = 0
        self.sharingCountO = 0
    }

    init(s: Int, n: Int) {
        self.size = s
        self.numPlayers = n
        self.winner = -1
        self.board = (0..<s).map { _ in (0..<s).map { _ in Piece() } }
        self.players = (0..<n).map { _ in Player() }
        self.threes = (0..<(n*8)).map { _ in (0..<7).map { _ in -1 } }
        self.numThrees = 0
        self.tie = false
        self.choosingThree = false
        self.gotEight = false
        self.feedCount = 0
        self.feed = ""
        self.gk = 8
        self.gc = 0
        self.ok = 8
        self.oc = 0
        self.boopChanges = (0..<(n*8)).map { _ in (0..<5).map { _ in -1 } }
        self.boopCount = 0
        self.choosingIndices = (0..<2).map { _ in (0..<4).map { _ in -1 } }
        self.sharingPoints = (0..<2).map { _ in (0..<50).map { _ in -1 } }
        self.sharingCountG = 0
        self.sharingCountO = 0
    }

    func insert(p: Int, i: Int, j: Int, t: Int) {
        //let temp = Piece(type: t, player: p)
        //board[i][j].copy(piece: temp)
        board[i][j].setPlayer(p: p)
        board[i][j].setType(t: t)
        players[p].insert(kittenOrCat: t)
        scoreUpdate(p: p, t: t, a: 1)
    }

    func remove(i: Int, j: Int, x: Int, y: Int, m: Int, n: Int) {
        // Coordinate pairs: ij, xy, mn
        var numKittens = 0
        let t1 = board[i][j].getType()
        let t2 = board[x][y].getType()
        let t3 = board[m][n].getType()
                
        if t1 == 1 { numKittens += 1 }
        if t2 == 1 { numKittens += 1 }
        if t3 == 1 { numKittens += 1 }

        if numKittens == 0 {
            if winner == -1 {
                winner = board[i][j].getPlayer()
            } else {
                print("Player \(board[i][j].getPlayer() + 1) has 3 cats in a row.")
                setFeed(f: "Player \(board[i][j].getPlayer() + 1) has 3 cats in a row.")
                tie = true
            }
        } else {
            let cats = 3 - numKittens
            for _ in 0..<cats {
                players[board[i][j].getPlayer()].booped(kittenOrCat: 2)
                scoreUpdate(p: board[i][j].getPlayer(), t: 2, a: 0)
            }
            
            print("Player \(board[i][j].getPlayer() + 1) got 3 in a row. The kittens now become Cats!")
            setFeed(f: "Player \(board[i][j].getPlayer() + 1) got 3 in a row. The kittens now become Cats!")
            
            players[board[i][j].getPlayer()].age(numKittens: numKittens)
            
            for _ in 0..<numKittens {
                scoreUpdate(p: board[i][j].getPlayer(), t: 2, a: 0)
            }
            
            // Remove pieces from the board
            boopChangesInsert(p: board[i][j].getPlayer(), t: board[i][j].getType(), i: i, j: j, a: 0)
            boopChangesInsert(p: board[x][y].getPlayer(), t: board[x][y].getType(), i: x, j: y, a: 0)
            boopChangesInsert(p: board[m][n].getPlayer(), t: board[m][n].getType(), i: m, j: n, a: 0)
            board[i][j].remove()
            board[x][y].remove()
            board[m][n].remove()
        }
    }

    func booped(i: Int, j: Int, t: Int) {
        
        let directions = [(-1, -1), (-1, 0), (-1, 1), (0, 1), (1, 1), (1, 0), (1, -1), (0, -1)]
            
        for direction in directions {
            let (dx, dy) = direction
            let newI = i + dx
            let newJ = j + dy
            
            // Check if within bounds
            if newI >= 0 && newI < size && newJ >= 0 && newJ < size {
                // If the spot is not available
                if !availableSpot(i: newI, j: newJ) {
                    if t == 2 || board[newI][newJ].getType() == 1 {
                        let nextI = newI + dx
                        let nextJ = newJ + dy
                        
                        // Check if the next spot is within bounds and available
                        if nextI >= 0 && nextI < size && nextJ >= 0 && nextJ < size && availableSpot(i: nextI, j: nextJ) {
                            //board[nextI][nextJ].copy(piece: board[newI][newJ])
                            board[nextI][nextJ].setPlayer(p: board[newI][newJ].getPlayer())
                            board[nextI][nextJ].setType(t: board[newI][newJ].getType())
                            boopChangesInsert(p: board[newI][newJ].getPlayer(), t: board[newI][newJ].getType(), i: newI, j: newJ, a: 0)
                            boopChangesInsert(p: board[nextI][nextJ].getPlayer(), t: board[nextI][nextJ].getType(), i: nextI, j: nextJ, a: 1)
                            board[newI][newJ].remove()
                        } else if nextI < 0 || nextJ < 0 || nextI >= size || nextJ >= size {
                            // Call booped function on player
                            let player = board[newI][newJ].getPlayer()
                            players[player].booped(kittenOrCat: board[newI][newJ].getType())
                            scoreUpdate(p: player, t: board[newI][newJ].getType(), a: 0)
                            boopChangesInsert(p: board[newI][newJ].getPlayer(), t: board[newI][newJ].getType(), i: newI, j: newJ, a: 0)
                            board[newI][newJ].remove()
                        }
                    }
                }
            }
        }
    }

    func turn(p: Int, i: Int, j: Int, t: Int) {
        insert(p: p, i: i, j: j, t: t)
        booped(i: i, j: j, t: t)
        
        if three() && winner != -1 {
            print("Player \(winner + 1) has 3 cats in a row.")
            setFeed(f: "Player \(winner + 1) has 3 cats in a row.")
        } else if eight() && winner != -1 {
            print("Player \(winner + 1) has 8 cats on the board.")
            setFeed(f: "Player \(winner + 1) has 8 cats on the board.")
        }
    }

    func printGame() {

        print()

        if size > 9 {
            print(" ", terminator: "")
        }

        for i in 1...size {
            if i > 10 {
                print(" \(i)", terminator: "")
            } else {
                print("  \(i)", terminator: "")
            }
        }
        print()

        for i in 0..<size {
            if size > 9 {
                if (i + 1) < 10 {
                    print("\(i + 1)  ", terminator: "")
                } else {
                    print("\(i + 1) ", terminator: "")
                }
            } else {
                print("\(i + 1) ", terminator: "")
            }

            for j in 0..<size {
                if board[i][j].getPlayer() == -1 {
                    print("-", terminator: "")
                    if j != (size - 1) {
                        print("  ", terminator: "")
                    }
                } else {
                    print("\(board[i][j].getPlayer() + 1)", terminator: "")
                    if board[i][j].getType() == 1 {
                        print("K", terminator: "")
                    } else if board[i][j].getType() == 2 {
                        print("C", terminator: "")
                    }
                    if j != (size - 1) {
                        print(" ", terminator: "")
                    }
                }
            }
            
            print()
            print()
        }

        for i in 0..<numPlayers {
            print("Player \(i + 1): Kitten = \(players[i].getKittens()) Cat = \(players[i].getCats())")
        }
        print()

    }

    func availableSpot(i: Int, j: Int) -> Bool {
        return board[i][j].getPlayer() == -1
    }

    func hasKittenOrCat(p: Int, t: Int) -> Bool {
        
        if t == 1 {
            return players[p].getKittens() > 0
        } else if t == 2 {
            return players[p].getCats() > 0
        }
        return false
    }

    func three() -> Bool {
        
        let max = numPlayers * 8
        numThrees = 0
        for i in 0..<max {
            for j in 0..<7 {
                threes[i][j] = -1
            }
        }

        var check = false
        for x in 0..<numPlayers {
            for i in 0..<size {
                for j in 0..<size {
                    if board[i][j].getPlayer() == x {
                        if searchAdjacent(i: i, j: j) {
                            check = true
                        }
                    }
                }
            }
        }

        if check {
            var currentPlayer = threes[0][0]
            var start = 0
            for end in 0..<max {
                if threes[end][0] == -1 {
                    chooseThree(s: start, e: end)
                    break
                } else if threes[end][0] != currentPlayer {
                    chooseThree(s: start, e: end)
                    currentPlayer = threes[end][0]
                    start = end
                }
            }
            
            return true
        }
        
        return false
    }

    func searchAdjacent(i: Int, j: Int) -> Bool {
        
        var check = false

        // To the right
        if (j + 1) >= 0 && (j + 1) < size {
            if board[i][j + 1].getPlayer() == board[i][j].getPlayer() {
                if (j + 2) >= 0 && (j + 2) < size {
                    if board[i][j + 2].getPlayer() == board[i][j].getPlayer() {
                        threes[numThrees] = [board[i][j].getPlayer(), i, j, i, (j + 1), i, (j + 2)]
                        numThrees += 1
                        check = true
                    }
                }
            }
        }

        // To the right and down diagonal
        if (i + 1) >= 0 && (i + 1) < size && (j + 1) >= 0 && (j + 1) < size {
            if board[i + 1][j + 1].getPlayer() == board[i][j].getPlayer() {
                if (i + 2) >= 0 && (i + 2) < size && (j + 2) >= 0 && (j + 2) < size {
                    if board[i + 2][j + 2].getPlayer() == board[i][j].getPlayer() {
                        threes[numThrees] = [board[i][j].getPlayer(), i, j, (i + 1), (j + 1), (i + 2), (j + 2)]
                        numThrees += 1
                        check = true
                    }
                }
            }
        }

        // Down
        if (i + 1) >= 0 && (i + 1) < size {
            if board[i + 1][j].getPlayer() == board[i][j].getPlayer() {
                if (i + 2) >= 0 && (i + 2) < size {
                    if board[i + 2][j].getPlayer() == board[i][j].getPlayer() {
                        threes[numThrees] = [board[i][j].getPlayer(), i, j, (i + 1), j, (i + 2), j]
                        numThrees += 1
                        check = true
                    }
                }
            }
        }

        // To the left and down diagonal
        if (i + 1) >= 0 && (i + 1) < size && (j - 1) >= 0 && (j - 1) < size {
            if board[i + 1][j - 1].getPlayer() == board[i][j].getPlayer() {
                if (i + 2) >= 0 && (i + 2) < size && (j - 2) >= 0 && (j - 2) < size {
                    if board[i + 2][j - 2].getPlayer() == board[i][j].getPlayer() {
                        threes[numThrees] = [board[i][j].getPlayer(), i, j, (i + 1), (j - 1), (i + 2), (j - 2)]
                        numThrees += 1
                        check = true
                    }
                }
            }
        }
        
        return check
    }

    func chooseThree(s: Int, e: Int) {
        
        if (e - s) == 1 {
            remove(i: threes[s][1], j: threes[s][2], x: threes[s][3], y: threes[s][4], m: threes[s][5], n: threes[s][6])
            return
        }
        
        var track = -1
        var check = false
        var sharing = false
        var playerSharingCount = -1
        
        if threes[s][0] == 0 {
            playerSharingCount = sharingCountG
        }
        else if threes[s][0] == 1 {
            playerSharingCount = sharingCountO
        }
        
        for i in s..<e {
            for j in s..<e {
                if i == j {
                    continue
                } else {
                    for k in stride(from: 1, to: 6, by: 2) {
                        for l in stride(from: 1, to: 6, by: 2) {
                            if threes[i][k] == threes[j][l] && threes[i][k+1] == threes[j][l+1] {
                                // They share a piece; the player must pick one of the three in a row
                                check = true
                                sharingPoints[threes[s][0]][playerSharingCount] = threes[i][k]
                                sharingPoints[threes[s][0]][playerSharingCount+1] = threes[i][k+1]
                                playerSharingCount += 2
                                
                                if (!sharing) {
                                    sharing = true
                                    choosingThree = true
                                    choosingIndices[threes[s][0]][0] = threes[s][0]
                                    choosingIndices[threes[s][0]][1] = s
                                    choosingIndices[threes[s][0]][2] = e
                                    //choosingIndices[threes[s][0]][3] = threes[i][k]
                                    //choosingIndices[threes[s][0]][4] = threes[i][k+1]
                                    print(choosingIndices)
                                    print("Player \(threes[s][0] + 1) has 3 in a row in multiple spots.")
                                }
                            }
                        }
                    }
                }
            }
            
            if !check {
                track = i
            }
            
            check = false
        }
        
        if !sharing {
            remove(i: threes[s][1], j: threes[s][2], x: threes[s][3], y: threes[s][4], m: threes[s][5], n: threes[s][6])
            remove(i: threes[s + 1][1], j: threes[s + 1][2], x: threes[s + 1][3], y: threes[s + 1][4], m: threes[s + 1][5], n: threes[s + 1][6])
        }
        else {
            choosingIndices[threes[s][0]][3] = track
        }
        
        if threes[s][0] == 0 {
            sharingCountG = playerSharingCount
        }
        else if threes[s][0] == 1 {
            sharingCountO = playerSharingCount
        }
    }
    
    func checkChooseThree(p: Int, s: Int, e: Int, c1: Int, c2: Int, c3: Int, c4: Int, c5: Int, c6: Int) -> Bool {
        
        var playerSharingCount = -1
        if p == 0 {
            playerSharingCount = sharingCountG
        }
        else if p == 1 {
            playerSharingCount = sharingCountO
        }
        
        for index in stride(from: 0, to: playerSharingCount, by: 2) {
            let row = sharingPoints[p][index]
            let col = sharingPoints[p][index+1]
            
            if ((c1 == row) && (c2 == col)) || ((c3 == row) && (c4 == col)) || ((c5 == row) && (c6 == col)) {
                if threeInARow(i: c1, j: c2, x: c3, y: c4, m: c5, n: c6) {
                    remove(i: c1, j: c2, x: c3, y: c4, m: c5, n: c6)
                    
                    if ((e - s) == 3) && (choosingIndices[p][3] != -1) {
                        print("last")
                        let notSharingThree = choosingIndices[p][3]
                        remove(i: threes[notSharingThree][1], j: threes[notSharingThree][2], x: threes[notSharingThree][3], y: threes[notSharingThree][4], m: threes[notSharingThree][5], n: threes[notSharingThree][6])
                    }
                    
                    choosingIndices[p][0] = -1
                    choosingIndices[p][1] = -1
                    choosingIndices[p][2] = -1
                    choosingIndices[p][3] = -1
                    
                    break
                    
                } else {
                    print("Player \(p+1), please select 3 in a row that share a spot with another 3 in a row.")
                    setFeed(f: "Player \(p+1), please select 3 in a row that share a spot with another 3 in a row.")
                    //return false
                }
            } else {
                print("Player \(p+1), please select 3 in a row that are sharing a spot with another 3 in a row.")
                setFeed(f: "Player \(p+1), please select 3 in a row that are sharing a spot with another 3 in a row.")
                //return false
            }
        }
        
        return choosingIndices[p][0] == -1
    }

    func threeInARow(i: Int, j: Int, x: Int, y: Int, m: Int, n: Int) -> Bool {
        // Coordinate pairs: ij xy mn
        if ((i == x && j == y) || (i == m && j == n) || (x == m && y == n)) {
            return false
        }

        var first: Int, second: Int, third: Int, fourth: Int, fifth: Int, sixth: Int

        if compareCoordinates(r1: i, c1: j, r2: x, c2: y) {
            if compareCoordinates(r1: i, c1: j, r2: m, c2: n) {
                first = i
                second = j
                if compareCoordinates(r1: x, c1: y, r2: m, c2: n) {
                    third = x
                    fourth = y
                    fifth = m
                    sixth = n
                } else {
                    third = m
                    fourth = n
                    fifth = x
                    sixth = y
                }
            } else {
                first = m
                second = n
                third = i
                fourth = j
                fifth = x
                sixth = y
            }
        } else {
            if compareCoordinates(r1: x, c1: y, r2: m, c2: n) {
                first = x
                second = y
                if compareCoordinates(r1: i, c1: j, r2: m, c2: n) {
                    third = i
                    fourth = j
                    fifth = m
                    sixth = n
                } else {
                    third = m
                    fourth = n
                    fifth = i
                    sixth = j
                }
            } else {
                first = m
                second = n
                third = x
                fourth = y
                fifth = i
                sixth = j
            }
        }

        if checkAdjacent(i: (first + 1), j: (second + 1), x: (third + 1), y: (fourth + 1), m: (fifth + 1), n: (sixth + 1)) {
            return true
        }
        
        return false
    }

    func checkAdjacent(i: Int, j: Int, x: Int, y: Int, m: Int, n: Int) -> Bool {
        if (i == x && (j + 1) == y && i == m && (j + 2) == n) {
            return true
        } else if ((i + 1) == x && (j + 1) == y && (i + 2) == m && (j + 2) == n) {
            return true
        } else if ((i + 1) == x && j == y && (i + 2) == m && j == n) {
            return true
        } else if ((i + 1) == x && (j - 1) == y && (i + 2) == m && (j - 2) == n) {
            return true
        }
        
        return false
    }

    func compareCoordinates(r1: Int, c1: Int, r2: Int, c2: Int) -> Bool {
        if r1 < r2 {
            return true
        } else if r1 == r2 {
            if c1 < c2 {
                return true
            }
        }
        return false
    }

    func eight() -> Bool {
        for x in 0..<numPlayers {
            var numKittens = 0
            var numCats = 0
            
            for i in 0..<size {
                for j in 0..<size {
                    if board[i][j].getPlayer() == x {
                        if board[i][j].getType() == 1 {
                            numKittens += 1
                        } else if board[i][j].getType() == 2 {
                            numCats += 1
                        }
                    }
                }
            }
            
            if numCats == 8 {
                winner = x
                return true
            } else if ((numKittens + numCats) == 8) && !choosingThree {
                upgradeKitten(p: x)
                return true
            }
        }
        return false
    }

    func upgradeKitten(p: Int) {
        gotEight = true
        printGame()
        print("Player \(p + 1) has 8 pieces on the board. Please choose a kitten to remove and upgrade to a cat")
        setFeed(f: "Player \(p + 1) has 8 pieces on the board. Please choose a kitten to remove and upgrade to a cat")
    }
    
    func checkUpgrade(p: Int, i: Int, j: Int) -> Bool {
        if board[i][j].getPlayer() == p {
            if board[i][j].getType() == 1 {
                board[i][j].remove()
                players[p].age(numKittens: 1)
                scoreUpdate(p: p, t: 2, a: 0)
                gotEight = false
                return true
            } else {
                print("The piece you selected is a cat.")
                setFeed(f: "The piece you selected is a cat. Please select a kitten to upgrade.")
            }
        } else {
            print("You do not have a kitten in the spot you selected.")
            setFeed(f: "You do not have a kitten in the spot you selected. Please select one of your kittens to upgrade.")
        }
        
        return false
    }

    func setWinner(w: Int) {
        winner = w
    }
    
    func getWinner() -> Int {
        return winner
    }
    
    func setTie(t: Bool) {
        tie = t
    }

    func getTie() -> Bool {
        return tie
    }
    
    func setChoosingThree(c: Bool) {
        choosingThree = c
    }
    
    func getChoosingThree() -> Bool {
        return choosingThree
    }
    
    func setGotEight(c: Bool) {
        gotEight = c
    }
    
    func getGotEight() -> Bool {
        return gotEight
    }
    
    func setFeed(f: String) {
        feed = f
        feedCount += 1
    }
    
    func getFeed() -> String {
        return feed
    }
    
    func scoreUpdate(p: Int, t: Int, a: Int) {
        if p == 0 {
            if t == 1 {
                if a == 0 {
                    gk += 1
                }
                else if a == 1 {
                    gk -= 1
                }
            }
            else if t == 2 {
                if a == 0 {
                    gc += 1
                }
                else if a == 1 {
                    gc -= 1
                }
            }
        }
        else if p == 1 {
            if t == 1 {
                if a == 0 {
                    ok += 1
                }
                else if a == 1 {
                    ok -= 1
                }
            }
            else if t == 2 {
                if a == 0 {
                    oc += 1
                }
                else if a == 1 {
                    oc -= 1
                }
            }
        }
    }
    
    func setGK(c: Int) {
        gk = c
    }
    
    func getGK() -> Int {
        return gk
    }
    
    func setGC(c: Int) {
        gc = c
    }
    
    func getGC() -> Int {
        return gc
    }
    
    func setOK(c: Int) {
        ok = c
    }
    
    func getOK() -> Int {
        return ok
    }
    
    func setOC(c: Int) {
        oc = c
    }
    
    func getOC() -> Int {
        return oc
    }
    
    func boopChangesInsert(p: Int, t: Int, i: Int, j: Int, a: Int) {
        boopChanges[boopCount][0] = p
        boopChanges[boopCount][1] = t
        boopChanges[boopCount][2] = i
        boopChanges[boopCount][3] = j
        boopChanges[boopCount][4] = a
        boopCount += 1
    }
}

