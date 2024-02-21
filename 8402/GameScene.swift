import SpriteKit

class GameScene: SKScene {
    
    let boardSize = 4
    var board: [[Int]] = []
    var touchStartPoint: CGPoint?

    var labelNode: SKLabelNode!
    var boardTopEdge: CGFloat = 0.0
    var score: Int = 0
    
    override func didMove(to view: SKView) {
        self.size = view.bounds.size
        
        let screenWidth = view.bounds.width
        let fontSize = screenWidth * 0.2
        
        let boardSize = CGFloat(self.boardSize)
        let tileSize = CGSize(width: 100, height: 100)
        let tileSpacing: CGFloat = 10
        let totalHeight = boardSize * tileSize.height + (boardSize - 1) * tileSpacing
        let boardYPosition = -totalHeight / 2
        
        
        let labelYPosition = boardYPosition + totalHeight + 50
        
        labelNode = SKLabelNode(text: "2048")
        labelNode.fontSize = fontSize
        labelNode.fontName = UIFont.boldSystemFont(ofSize: fontSize).fontName
        labelNode.fontColor = .white
        labelNode.position = CGPoint(x: frame.midX, y: labelYPosition)
        addChild(labelNode)
        
        
        initializeBoard()
        displayBoard()
        addChild(labelNode)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStartPoint = touches.first?.location(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let startPoint = touchStartPoint,
              let endPoint = touches.first?.location(in: self) else {
            return
        }
        
        let deltaX = endPoint.x - startPoint.x
        let deltaY = endPoint.y - startPoint.y
        
        if abs(deltaX) > abs(deltaY) {
            if deltaX > 0 {
                moveRight()
            } else {
                moveLeft()
            }
        } else {
            if deltaY > 0 {
                moveUp()
            } else {
                moveDown()
            }
        }
        
        touchStartPoint = nil
        
        if isGameOver() {
            gameOver()
        }
    }
    
    func initializeBoard() {
        board = [[Int]](repeating: [Int](repeating: 0, count: boardSize), count: boardSize)
        placeRandomTile()
        placeRandomTile()
    }
    
    func placeRandomTile() {
        var emptyCells: [(Int, Int)] = []
        for i in 0..<boardSize {
            for j in 0..<boardSize {
                if board[i][j] == 0 {
                    emptyCells.append((i, j))
                }
            }
        }
        guard let randomCell = emptyCells.randomElement() else { return }
        let randomNumber = Int.random(in: 1...2) * 2
        board[randomCell.0][randomCell.1] = randomNumber
    }
    
    func displayBoard() {
        removeAllChildren()
        
        let tileSize = CGSize(width: 100, height: 100)
        let tileSpacing: CGFloat = 10
        
        let totalWidth = CGFloat(boardSize) * tileSize.width + CGFloat(boardSize - 1) * tileSpacing
        let totalHeight = CGFloat(boardSize) * tileSize.height + CGFloat(boardSize - 1) * tileSpacing
        
        let startX = -totalWidth / 2 + tileSize.width / 2
        let startY = -totalHeight / 2 + tileSize.height / 2
        
        for i in 0..<boardSize {
            for j in 0..<boardSize {
                let tileValue = board[i][j]
                let tileNode = SKLabelNode(text: "\(tileValue)")
                tileNode.fontSize = 36
                tileNode.fontColor = .white
                tileNode.horizontalAlignmentMode = .center
                tileNode.verticalAlignmentMode = .center
                tileNode.position = CGPoint(x: startX + CGFloat(j) * (tileSize.width + tileSpacing),
                                            y: startY + CGFloat(i) * (tileSize.height + tileSpacing))
                tileNode.zPosition = 1
                tileNode.name = "Tile\(i)-\(j)"
                addChild(tileNode)
                
                let tileColor = tileValue > 0 ? UIColor(red: 1.0 - CGFloat(tileValue) / 20.0, green: 0.5, blue: 0.5, alpha: 1.0) : .clear
                let tileBackground = SKSpriteNode(color: tileColor, size: tileSize)
                tileBackground.position = CGPoint(x: startX + CGFloat(j) * (tileSize.width + tileSpacing),
                                                  y: startY + CGFloat(i) * (tileSize.height + tileSpacing))
                tileBackground.zPosition = 0
                addChild(tileBackground)
            }
        }
        
    }
    func moveLeft() {
        var merged = [[Bool]](repeating: [Bool](repeating: false, count: boardSize), count: boardSize)
        for i in 0..<boardSize {
            var lastMergedIndex = -1
            for j in 1..<boardSize {
                if board[i][j] != 0 {
                    var k = j
                    while k > 0 && (board[i][k - 1] == 0 || (board[i][k - 1] == board[i][k] && !merged[i][k - 1])) {
                        if board[i][k - 1] == board[i][k] {
                            if lastMergedIndex != k - 1 {
                                board[i][k - 1] *= 2
                                board[i][k] = 0
                                merged[i][k - 1] = true
                                lastMergedIndex = k - 1
                            }
                            break
                        } else {
                            board[i][k - 1] = board[i][k]
                            board[i][k] = 0
                            k -= 1
                        }
                    }
                }
            }
        }
        placeRandomTile()
        displayBoard()
        addChild(labelNode)
    }

    func moveRight() {
        var merged = [[Bool]](repeating: [Bool](repeating: false, count: boardSize), count: boardSize)
        for i in 0..<boardSize {
            var lastMergedIndex = boardSize
            for j in (0..<boardSize-1).reversed() {
                if board[i][j] != 0 {
                    var k = j
                    while k < boardSize - 1 && (board[i][k + 1] == 0 || (board[i][k + 1] == board[i][k] && !merged[i][k + 1])) {
                        if board[i][k + 1] == board[i][k] {
                            if lastMergedIndex != k + 1 {
                                board[i][k + 1] *= 2
                                board[i][k] = 0
                                merged[i][k + 1] = true
                                lastMergedIndex = k + 1
                            }
                            break
                        } else {
                            board[i][k + 1] = board[i][k]
                            board[i][k] = 0
                            k += 1
                        }
                    }
                }
            }
        }
        placeRandomTile()
        displayBoard()
        addChild(labelNode)
    }
    func moveDown() {
        var merged = [[Bool]](repeating: [Bool](repeating: false, count: boardSize), count: boardSize)
        for j in 0..<boardSize {
            var lastMergedIndex = -1
            for i in 1..<boardSize {
                if board[i][j] != 0 {
                    var k = i
                    while k > 0 && (board[k - 1][j] == 0 || board[k - 1][j] == board[k][j]) {
                        if board[k - 1][j] == board[k][j] && !merged[k - 1][j] && lastMergedIndex != k - 1 {
                            board[k - 1][j] *= 2
                            board[k][j] = 0
                            merged[k - 1][j] = true
                            lastMergedIndex = k - 1
                            break
                        } else if board[k - 1][j] != board[k][j] {
                            board[k - 1][j] = board[k][j]
                            board[k][j] = 0
                        }
                        k -= 1
                    }
                }
            }
        }
        placeRandomTile()
        displayBoard()
        addChild(labelNode)
    }

    func moveUp() {
        var merged = [[Bool]](repeating: [Bool](repeating: false, count: boardSize), count: boardSize)
        for j in 0..<boardSize {
            var lastMergedIndex = boardSize
            for i in (0..<boardSize-1).reversed() {
                if board[i][j] != 0 {
                    var k = i
                    while k < boardSize - 1 && (board[k + 1][j] == 0 || board[k + 1][j] == board[k][j]) {
                        if board[k + 1][j] == board[k][j] && !merged[k + 1][j] && lastMergedIndex != k + 1 {
                            board[k + 1][j] *= 2
                            board[k][j] = 0
                            merged[k + 1][j] = true
                            lastMergedIndex = k + 1
                            break
                        } else if board[k + 1][j] != board[k][j] {
                            board[k + 1][j] = board[k][j]
                            board[k][j] = 0
                        }
                        k += 1
                    }
                }
            }
        }
        placeRandomTile()
        displayBoard()
        addChild(labelNode)
    }


    func transposeBoard() {
        board = (0..<boardSize).map { i in
            (0..<boardSize).map { j in
                board[j][i]
            }
        }
    }
    func isBoardFull() -> Bool {
        for row in board {
            for cell in row {
                if cell == 0 {
                    return false
                }
            }
        }
        return true
    }

    func canMove() -> Bool {
        for i in 0..<boardSize {
            for j in 0..<boardSize {
                if j + 1 < boardSize && board[i][j] == board[i][j + 1] {
                    return true
                }
                if i + 1 < boardSize && board[i][j] == board[i + 1][j] {
                    return true
                }
            }
        }
        return false
    }

    func isGameOver() -> Bool {
        return isBoardFull() && !canMove()
    }
    func gameOver() {
        let transition = SKTransition.fade(withDuration: 0.5)
        let gameOverScene = GameOverScene(size: self.size)
        view?.presentScene(gameOverScene, transition: transition)
    }
    

}

class GameOverScene: SKScene {
    
    override func didMove(to view: SKView) {
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontSize = 48
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(gameOverLabel)
        
        let tryAgainButton = SKLabelNode(text: "Try Again")
        tryAgainButton.fontSize = 24
        tryAgainButton.fontColor = .white
        tryAgainButton.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        tryAgainButton.name = "tryAgainButton"
        addChild(tryAgainButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        for node in nodes {
            if node.name == "tryAgainButton" {
                resetGame()
            }
        }
    }
    
    func resetGame() {
        if let gameScene = SKScene(fileNamed: "GameScene") as? GameScene {
            gameScene.scaleMode = .aspectFill
            view?.presentScene(gameScene, transition: .fade(withDuration: 0.5))
        }
    }

}
