import Foundation
import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var boardSize = 6
    var numPlayers = 2
    var game: Game = Game(s: 6, n: 2)
    var squares = [SKSpriteNode]()
    var choice = 1
    @objc dynamic var turn = 0
    @objc dynamic var gameOver = false
    var choiceThree = (0..<6).map { _ in -1 }
    var choiceThreeCount = 0
    
    var s1 = UIColor()
    var s2 = UIColor()
    var s3 = UIColor()
    
    @objc dynamic var undoIsPossible = false
    var undo: Undo = Undo()
    
    override func didMove(to view: SKView) {
        initBackground()
        drawBoard()
    }
    
    func initBackground(){
        
        let background = SKSpriteNode(imageNamed: "background.png")
        background.position = CGPoint(x: ((view?.bounds.width ?? 0) / 2), y: ((view?.bounds.height ?? 0) / 2))
        addChild(background)
        
        let title = SKSpriteNode(imageNamed: "title.png")
        title.position = CGPoint(x: ((view?.bounds.width ?? 0) / 2), y: ((view?.bounds.height ?? 0) * (0.90)))
        addChild(title)
        
        let kittens = SKSpriteNode(imageNamed: "kittens.png")
        kittens.position = CGPoint(x: 34, y: 676)
        addChild(kittens)
        
        let cats = SKSpriteNode(imageNamed: "cats.png")
        cats.position = CGPoint(x: 175, y: 676)
        addChild(cats)
        
        game.setFeed(f: "Welcome to Boop! Boop is a game where kittens bounce each other around a quilted bed in a chaotic quest to grow up into cats and form the purr-fect lineup! Player \(turn + 1), it is your turn.")
    }
    
    func drawBoard() {
        
        // Board parameters
        let squareSide = (view?.bounds.width ?? 0) / CGFloat(boardSize)
        let squareSize = CGSize(width: squareSide, height: squareSide)
        let xOffset:CGFloat = 33.5
        let yOffset:CGFloat = 200
        let color1 = UIColor(red: 59/255, green: 161/255, blue: 217/255, alpha: 1.0)
        let color2 = UIColor(red: 148/255, green: 188/255, blue: 209/255, alpha: 1.0)

        for row in 0..<boardSize {
            for col in 0..<boardSize {
                let color = (row + col) % 2 == 0 ? color1 : color2
                let square = SKSpriteNode(color: color, size: squareSize)
                square.position = CGPoint(x: CGFloat(col) * squareSize.width + xOffset, y: CGFloat(row) * squareSize.height + yOffset)
                
                square.name = "\((boardSize-1)-row)\(col)"
                addChild(square)
            }
        }
    }
    
    /** Draws pawns on top of board */
    func drawPieces() {
        let squareSide = (view?.bounds.width ?? 0) / CGFloat(boardSize)
        
        //Grey Kitten pieces
        for row in 0..<1 {
            for col in 0...5 {
                if let square = squareWithName(name: "\((boardSize-1)-row)\(col)") {
                    let gamePiece = SKSpriteNode(imageNamed: "Grey Kitten")
                    gamePiece.size = CGSize(width: squareSide, height: squareSide)
                    gamePiece.name = "gk\((boardSize-1)-row)\(col)"
                    square.addChild(gamePiece)
                }
            }
        }
        
        //Grey Cat pieces
        for row in 1..<2 {
            for col in 0...5 {
                if let square = squareWithName(name: "\((boardSize-1)-row)\(col)") {
                    let gamePiece = SKSpriteNode(imageNamed: "Grey Cat")
                    gamePiece.size = CGSize(width: squareSide, height: squareSide)
                    gamePiece.name = "gc\((boardSize-1)-row)\(col)"
                    square.addChild(gamePiece)
                }
            }
        }
        
        //Orange Cat pieces
        for row in 4..<5 {
            for col in 0...5 {
                if let square = squareWithName(name: "\((boardSize-1)-row)\(col)") {
                    let gamePiece = SKSpriteNode(imageNamed: "Orange Cat")
                    gamePiece.size = CGSize(width: squareSide, height: squareSide)
                    gamePiece.name = "oc\((boardSize-1)-row)\(col)"
                    square.addChild(gamePiece)
                }
            }
        }
        
        //Orange Kitten pieces
        for row in 5..<6 {
            for col in 0...5 {
                if let square = squareWithName(name: "\((boardSize-1)-row)\(col)") {
                    let gamePiece = SKSpriteNode(imageNamed: "Orange Kitten")
                    gamePiece.size = CGSize(width: squareSide, height: squareSide)
                    gamePiece.name = "ok\((boardSize-1)-row)\(col)"
                    square.addChild(gamePiece)
                }
            }
        }
    }
    
    /** Decide what to do with when a touch begins */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (!game.getChoosingThree()) && (!game.getGotEight() && (!gameOver)) {
            setPrevState()
        }
        
        let touch:UITouch = touches.first!
        let positionInScene = touch.location(in: self)
        let touchedNode = atPoint(positionInScene)
        
        if gameOver {
            return
        }
        else if game.getChoosingThree() {
            chooseThree(p: turn, n: touchedNode)
            return
        }
        else if game.getGotEight() {
            upgradeKitten(p: turn, n: touchedNode)
            return
        }
        
        //game.printGame()
        
        if let name = touchedNode.name {
            
            if ((Array(name)[0] == "g") || (Array(name)[0] == "o")) {
                game.setFeed(f: "The spot you selected is already occupied by another kitten or cat. Player \(turn + 1), please select a different spot.")
            }
            else if !game.hasKittenOrCat(p: turn, t: choice) {
                if choice == 1 {
                    game.setFeed(f: "You do not have any kittens, so you must choose a cat. Player \(turn + 1), please choose a cat to place instead.")
                } else if choice == 2 {
                    game.setFeed(f: "You do not have any cats, so you must choose a kitten. Player \(turn + 1), please choose a kitten to place instead.")
                }
            }
            else {
                let row = rowFromNameSquare(name: name)
                let col = colFromNameSquare(name: name)
                game.turn(p: turn, i: row, j: col, t: choice)
                addPiece(row: row, col: col)
                undoIsPossible = true
                
                // make changes to pieces due to boop
                updateBoard()
                
                if game.getTie() {
                    print("The game is a draw.")
                    game.setFeed(f: "The game is a draw.")
                    game.printGame()
                    gameOver = true
                    return
                }
                else if game.getWinner() != -1 {
                    print("Player \(game.getWinner() + 1) has won the game!")
                    game.setFeed(f: "Player \(game.getWinner() + 1) has won the game!")
                    game.printGame()
                    gameOver = true
                    return
                }
                else if game.getChoosingThree() {
                    playerChoosingFeed(t: turn)
                    return
                }
                else if game.getGotEight() {
                    return
                }
                
                turn += 1
                
                if turn == 1 {
                    game.setFeed(f: "Player \(turn + 1), it is your turn.")
                }
            }
        }
        
        if turn > 1 {
            turn = 0
            game.setFeed(f: "Player \(turn + 1), it is your turn.")
        }
    }
    
    func rowFromNameSquare(name: String) -> Int {
        return Int(String(Array(name)[0]))!
    }
    
    func colFromNameSquare(name: String) -> Int {
        return Int(String(Array(name)[1]))!
    }
    
    func rowFromFullSquare(name: String) -> Int {
        return Int(String(Array(name)[2]))!
    }
    
    func colFromFullSquare(name: String) -> Int {
        return Int(String(Array(name)[3]))!
    }
    
    func squareWithName(name:String) -> SKSpriteNode? {
        let square:SKSpriteNode? = self.childNode(withName: name) as! SKSpriteNode?
        return square
    }
    
    func addPiece(row: Int, col: Int) {
        let squareSide = (view?.bounds.width ?? 0) / CGFloat(boardSize)
        if let square = squareWithName(name: "\(row)\(col)") {
            if turn == 0 {
                if choice == 1 {
                    let gamePiece = SKSpriteNode(imageNamed: "Grey Kitten")
                    gamePiece.size = CGSize(width: squareSide, height: squareSide)
                    gamePiece.name = "gk\(row)\(col)"
                    square.addChild(gamePiece)
                }
                else if choice == 2 {
                    let gamePiece = SKSpriteNode(imageNamed: "Grey Cat")
                    gamePiece.size = CGSize(width: squareSide, height: squareSide)
                    gamePiece.name = "gc\(row)\(col)"
                    square.addChild(gamePiece)
                }
            }
            else if turn == 1 {
                if choice == 1 {
                    let gamePiece = SKSpriteNode(imageNamed: "Orange Kitten")
                    gamePiece.size = CGSize(width: squareSide, height: squareSide)
                    gamePiece.name = "ok\(row)\(col)"
                    square.addChild(gamePiece)
                }
                else if choice == 2 {
                    let gamePiece = SKSpriteNode(imageNamed: "Orange Cat")
                    gamePiece.size = CGSize(width: squareSide, height: squareSide)
                    gamePiece.name = "oc\(row)\(col)"
                    square.addChild(gamePiece)
                }
            }
        }
    }
    
    func updateBoard() {
        
        for index in 0..<game.boopCount {
            if game.boopChanges[index][4] == 0 {
                if let square = squareWithName(name: "\(game.boopChanges[index][2])\(game.boopChanges[index][3])") {
                    square.removeAllChildren()
                }
            }
            else if game.boopChanges[index][4] == 1 {
                let squareSide = (view?.bounds.width ?? 0) / CGFloat(boardSize)
                if let square = squareWithName(name: "\(game.boopChanges[index][2])\(game.boopChanges[index][3])") {
                    if (game.boopChanges[index][0] == 0) {
                        var temp: String = ""
                        var temp2: String = ""
                        
                        if game.boopChanges[index][1] == 1 {
                            temp = "Grey Kitten"
                            temp2 = "gk"
                        }
                        else if game.boopChanges[index][1] == 2 {
                            temp = "Grey Cat"
                            temp2 = "gc"
                        }
                        
                        let gamePiece = SKSpriteNode(imageNamed: temp)
                        gamePiece.size = CGSize(width: squareSide, height: squareSide)
                        gamePiece.name = "\(temp2)\(game.boopChanges[index][2])\(game.boopChanges[index][3])"
                        square.addChild(gamePiece)
                    }
                    else if game.boopChanges[index][0] == 1 {
                        var temp: String = ""
                        var temp2: String = ""
                        
                        if game.boopChanges[index][1] == 1 {
                            temp = "Orange Kitten"
                            temp2 = "ok"
                        }
                        else if game.boopChanges[index][1] == 2 {
                            temp = "Orange Cat"
                            temp2 = "oc"
                        }
                        
                        let gamePiece = SKSpriteNode(imageNamed: temp)
                        gamePiece.size = CGSize(width: squareSide, height: squareSide)
                        gamePiece.name = "\(temp2)\(game.boopChanges[index][2])\(game.boopChanges[index][3])"
                        square.addChild(gamePiece)
                    }
                }
            }
        }
        
        game.boopChanges = (0..<(numPlayers*8)).map { _ in (0..<5).map { _ in -1 } }
        game.boopCount = 0
    }
    
    func upgradeKitten(p: Int, n: SKNode) {
        if let name = n.name {
            if ((Array(name)[0] == "g") || (Array(name)[0] == "o")) {
                let row = rowFromFullSquare(name: name)
                let col = colFromFullSquare(name: name)
                
                if game.checkUpgrade(p: p, i: row, j: col) {
                    if let square = squareWithName(name: "\(row)\(col)") {
                        square.removeAllChildren()
                    }
                    
                    turn += 1
                    if turn > 1 {
                        turn = 0
                        game.setFeed(f: "Player \(turn + 1), it is your turn.")
                    }
                    else if turn == 1 {
                        game.setFeed(f: "Player \(turn + 1), it is your turn.")
                    }
                }
            }
            else {
                print("You do not have a kitten in the spot you selected.")
                game.setFeed(f: "You do not have a kitten in the spot you selected. Please select one of your kittens to upgrade.")
            }
        }
    }
    
    func chooseThree(p: Int, n: SKNode) {
        if let name = n.name {
            let pc = playerChoosing(t: p)
            if (((Array(name)[0] == "g") && (pc == 0)) || ((Array(name)[0] == "o") && (pc == 1))) {
                let row = rowFromFullSquare(name: name)
                let col = colFromFullSquare(name: name)
                
                if (choiceThree[0] == row) && (choiceThree[1] == col) {
                    if let square1 = squareWithName(name: "\(choiceThree[0])\(choiceThree[1])") {
                        square1.color = s1
                        square1.colorBlendFactor = 0
                    }
                    
                    choiceThree[0] = -1
                    choiceThree[1] = -1
                    choiceThreeCount -= 2
                    return
                }
                else if (choiceThree[2] == row) && (choiceThree[3] == col) {
                    if let square2 = squareWithName(name: "\(choiceThree[2])\(choiceThree[3])") {
                        square2.color = s2
                        square2.colorBlendFactor = 0
                    }
                    
                    choiceThree[2] = -1
                    choiceThree[3] = -1
                    choiceThreeCount -= 2
                    return
                }
                else if (choiceThree[4] == row) && (choiceThree[5] == col) {
                    if let square3 = squareWithName(name: "\(choiceThree[4])\(choiceThree[5])") {
                        square3.color = s3
                        square3.colorBlendFactor = 0
                    }
                    
                    choiceThree[4] = -1
                    choiceThree[5] = -1
                    choiceThreeCount -= 2
                    return
                }
                
                if choiceThreeCount < 4 {
                    choiceThree[choiceThreeCount] = row
                    choiceThree[choiceThreeCount + 1] = col
                    choiceThreeCount += 2
                                        
                    // tint piece
                    if let square = squareWithName(name: "\(row)\(col)") {
                        
                        if choiceThreeCount == 2 {
                            s1 = square.color
                        }
                        else if choiceThreeCount == 4 {
                            s2 = square.color
                        }
                        
                        square.color = .white
                        square.colorBlendFactor = 0.5
                    }
                    
                }
                else {
                    choiceThree[choiceThreeCount] = row
                    choiceThree[choiceThreeCount + 1] = col
                    choiceThreeCount += 2
                                        
                    //tint last piece
                    if let square = squareWithName(name: "\(row)\(col)") {
                        s3 = square.color
                        square.color = .white
                        square.colorBlendFactor = 0.5
                    }
                    
                    if game.checkChooseThree(p: pc, s: game.choosingIndices[pc][1], e: game.choosingIndices[pc][2], c1: choiceThree[0], c2: choiceThree[1], c3: choiceThree[2], c4: choiceThree[3], c5: choiceThree[4], c6: choiceThree[5]) {
                                                
                        updateBoard()
                        
                        if game.getTie() {
                            print("The game is a draw.")
                            game.setFeed(f: "The game is a draw.")
                            game.printGame()
                            gameOver = true
                            return
                        }
                        else if game.getWinner() != -1 {
                            print("Player \(game.getWinner() + 1) has won the game!")
                            game.setFeed(f: "Player \(game.getWinner() + 1) has won the game!")
                            game.printGame()
                            gameOver = true
                            return
                        }
                        
                        if  (game.choosingIndices[0][0] == -1) && (game.choosingIndices[1][0] == -1) {
                            
                            game.setChoosingThree(c: false)
                            game.choosingIndices = (0..<numPlayers).map { _ in (0..<4).map { _ in -1 } }
                            game.sharingPoints = (0..<numPlayers).map { _ in (0..<50).map { _ in -1 } }
                            game.sharingCountG = 0
                            game.sharingCountO = 0
                            
                            turn += 1
                            if turn > 1 {
                                turn = 0
                                game.setFeed(f: "Player \(turn + 1), it is your turn.")
                            }
                            else if turn == 1 {
                                game.setFeed(f: "Player \(turn + 1), it is your turn.")
                            }
                        }
                        else {
                            playerChoosingFeed(t: turn)
                        }
                    }
                    
                    // remove tint
                    if let square1 = squareWithName(name: "\(choiceThree[0])\(choiceThree[1])") {
                        square1.color = s1
                        square1.colorBlendFactor = 0
                    }
                    
                    if let square2 = squareWithName(name: "\(choiceThree[2])\(choiceThree[3])") {
                        square2.color = s2
                        square2.colorBlendFactor = 0
                    }
                    
                    if let square3 = squareWithName(name: "\(choiceThree[4])\(choiceThree[5])") {
                        square3.color = s3
                        square3.colorBlendFactor = 0
                    }
                    
                    choiceThree = (0..<6).map { _ in -1 }
                    choiceThreeCount = 0
                }
            }
            else {
                print("You do not have a kitten or cat in the spot you selected.")
                game.setFeed(f: "You do not have a kitten or cat in the spot you selected. Please choose the 3 in a row you want to upgrade since some are sharing the same spot.")
                return
            }
        }
    }
    
    func playerChoosing(t: Int) -> Int {
        
        var result = -1
        if t == 0 {
            if game.choosingIndices[t][0] != -1 {
                result = 0
            }
            else if game.choosingIndices[t+1][0] != -1{
                result = 1
            }
        }
        else if t == 1 {
            if game.choosingIndices[t][0] != -1 {
                result = 1
            }
            else if game.choosingIndices[t-1][0] != -1 {
                result = 0
            }
        }
        
        game.setFeed(f: "Player \(result + 1) has 3 in a row in multiple spots. Please choose the 3 in a row you want to upgrade since some are sharing the same spot.")
        
        return result
    }
    
    func playerChoosingFeed(t: Int) {
        var result = -1
        if t == 0 {
            if game.choosingIndices[t][0] != -1 {
                result = 0
            }
            else if game.choosingIndices[t+1][0] != -1{
                result = 1
            }
        }
        else if t == 1 {
            if game.choosingIndices[t][0] != -1 {
                result = 1
            }
            else if game.choosingIndices[t-1][0] != -1 {
                result = 0
            }
        }
        
        game.setFeed(f: "Player \(result + 1) has 3 in a row in multiple spots. Please choose the 3 in a row you want to upgrade since some are sharing the same spot.")
    }
    
    func reset() {
        turn = 0
        choice = 1
        choiceThree = (0..<6).map { _ in -1 }
        choiceThreeCount = 0
        gameOver = false
        
        //reset board
        for i in 0..<boardSize {
            for j in 0..<boardSize {
                if game.board[i][j].getPlayer() != -1 {
                    if let square = squareWithName(name: "\(i)\(j)") {
                        square.removeAllChildren()
                    }
                }
            }
        }
        
        game = Game(s: 6, n: 2)
        undoIsPossible = false
    }
    
    func startFeed() {
        game.setFeed(f: "Welcome to Boop! Boop is a game where kittens bounce each other around a quilted bed in a chaotic quest to grow up into cats and form the purr-fect lineup! Player \(turn + 1), it is your turn.")
    }
    
    func undoVars() {
        
        // remove tint if was choosingThree
        if (game.getChoosingThree()) && (choiceThreeCount > 0) {
            for i in stride(from: 0, to: choiceThreeCount, by: 2) {
                if let square = squareWithName(name: "\(choiceThree[i])\(choiceThree[i+1])") {
                    if i == 0 {
                        square.color = s1
                    }
                    else if i == 2 {
                        square.color = s2
                    }
                    square.colorBlendFactor = 0
                }
            }
        }
        
        // revert board pieces to prev turn positions
        undoBoardPieces()
        
        // assign GameScene prev values
        choice = undo.choice
        turn = undo.turn
        gameOver = undo.gameOver
        
        // reset GameScene vars
        choiceThree = (0..<6).map { _ in -1 }
        choiceThreeCount = 0
        
        // assign Game prev values
        game.setWinner(w: undo.winner)
        
        for i in 0..<boardSize {
            for j in 0..<boardSize {
                game.board[i][j].setPlayer(p: undo.board[i][j].getPlayer())
                game.board[i][j].setType(t: undo.board[i][j].getType())
            }
        }
        
        for i in 0..<numPlayers {
            game.players[i].setKittens(k: undo.players[i].getKittens())
            game.players[i].setCats(c: undo.players[i].getCats())
        }
        
        game.setTie(t: undo.tie)
        game.setChoosingThree(c: undo.choosingThree)
        game.setGotEight(c: undo.gotEight)
        game.feedCount -= 1
        game.setFeed(f: undo.feed)
        game.gk = undo.gk
        game.gc = undo.gc
        game.ok = undo.ok
        game.oc = undo.oc
        
        // reset Game vars
        game.boopChanges = (0..<(numPlayers*8)).map { _ in (0..<5).map { _ in -1 } }
        game.boopCount = 0
        game.choosingIndices = (0..<numPlayers).map { _ in (0..<4).map { _ in -1 } }
        game.sharingPoints = (0..<numPlayers).map { _ in (0..<50).map { _ in -1 } }
        game.sharingCountG = 0
        game.sharingCountO = 0
        
        undoIsPossible = false
    }
    
    func undoBoardPieces() {
        
        for row in 0..<boardSize {
            for col in 0..<boardSize {
                let p = undo.board[row][col].getPlayer()
                let t = undo.board[row][col].getType()
                
                if (p == -1) && (t == 0) {
                    if let square = squareWithName(name: "\(row)\(col)") {
                        square.removeAllChildren()
                    }
                }
                else {
                    let squareSide = (view?.bounds.width ?? 0) / CGFloat(boardSize)
                    if let square = squareWithName(name: "\(row)\(col)") {
                        if !square.children.isEmpty {
                            square.removeAllChildren()
                        }
                        
                        if p == 0 {
                            var temp: String = ""
                            var temp2: String = ""
                            
                            if t == 1 {
                                temp = "Grey Kitten"
                                temp2 = "gk"
                            }
                            else if t == 2 {
                                temp = "Grey Cat"
                                temp2 = "gc"
                            }
                            
                            let gamePiece = SKSpriteNode(imageNamed: temp)
                            gamePiece.size = CGSize(width: squareSide, height: squareSide)
                            gamePiece.name = "\(temp2)\(row)\(col)"
                            square.addChild(gamePiece)
                        }
                        else if p == 1 {
                            var temp: String = ""
                            var temp2: String = ""
                            
                            if t == 1 {
                                temp = "Orange Kitten"
                                temp2 = "ok"
                            }
                            else if t == 2 {
                                temp = "Orange Cat"
                                temp2 = "oc"
                            }
                            
                            let gamePiece = SKSpriteNode(imageNamed: temp)
                            gamePiece.size = CGSize(width: squareSide, height: squareSide)
                            gamePiece.name = "\(temp2)\(row)\(col)"
                            square.addChild(gamePiece)
                        }
                    }
                }
            }
        }
    }
    
    func setPrevState() {
        
        // setting GameScene prev state
        undo.choice = choice
        undo.turn = turn
        undo.gameOver = gameOver
        
        // setting Game prev state
        undo.winner = game.getWinner()
        
        for i in 0..<boardSize {
            for j in 0..<boardSize {
                undo.board[i][j].setPlayer(p: game.board[i][j].getPlayer())
                undo.board[i][j].setType(t: game.board[i][j].getType())
            }
        }
        
        for i in 0..<numPlayers {
            undo.players[i].setKittens(k: game.players[i].getKittens())
            undo.players[i].setCats(c: game.players[i].getCats())
        }
        
        undo.tie = game.getTie()
        undo.choosingThree = game.getChoosingThree()
        undo.gotEight = game.getGotEight()
        undo.feed = game.getFeed()
        undo.gk = game.gk
        undo.gc = game.gc
        undo.ok = game.ok
        undo.oc = game.oc
    }
    
}
