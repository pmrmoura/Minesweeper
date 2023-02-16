final class Board {
    // MARK: - Private properties
    private let row: Int
    private let column: Int
    private let mines: Int
    private var board: [[Int]]
    private var foggedBoard: [[Int]]
    
    init(row: Int = 8, column: Int = 8, mines: Int = 10, board: [[Int]] = [], foggedBoard: [[Int]] = []) {
        self.row = row
        self.column = column
        self.mines = mines
        self.board = board
        self.foggedBoard = foggedBoard
    }
    
    // MARK: - Private methods
    
    private func placeMinesInBoard() {
        for _ in 0..<mines {
            let randomRow = Int.random(in: 0..<row)
            let randomColumn = Int.random(in: 0..<column)
            board[randomRow][randomColumn] = -1
        }
    }
    
    private func calculateNumberOfMinesSurroundingEachCell() {
        for i in 0..<row {
            for j in 0..<column {
                foggedBoard[i][j] = -2
                if board[i][j] == -1 {
                    continue
                }
                var count = 0
                for x in i-1...i+1 {
                    for y in j-1...j+1 {
                        if x >= 0 && x < row && y >= 0 && y < column && board[x][y] == -1 {
                            count += 1
                        }
                    }
                }
                board[i][j] = count
            }
        }
    }
    
    private func checkWinCondition() -> Bool {
        var won = true
        for i in 0..<row {
            for j in 0..<column {
                if i >= 0 && i < row && j >= 0 && j < column && board[i][j] != -1 {
                    if foggedBoard[i][j] != board[i][j] {
                        won = false
                    }
                }
            }
        }
        
        return won
    }
    
    private func findNumber(x: Int, y: Int) {
        guard x >= 0 && x < row && y >= 0 && y < column else { return }
        
        if foggedBoard[x][y] != -2 {
            return
        }
        
        foggedBoard[x][y] = board[x][y]
        
        if board[x][y] != 0 {
            return
        }
        
        for i in x - 1...x + 1 {
            for j in y - 1...y+1 {
                findNumber(x: j, y: i)
            }
        }
    }
    
    // MARK: - Methods
    
    func startBoard() {
        board = [[Int]](repeating: [Int](repeating: 0, count: column), count: row)
        foggedBoard = board
        placeMinesInBoard()
        calculateNumberOfMinesSurroundingEachCell()
    }
    
    func printBoard() -> Void {
        for i in 0..<row {
            for j in 0..<column {
                switch foggedBoard[i][j] {
                case -1:
                    print("*", terminator: " ")
                case -2:
                    print("#", terminator: " ")
                default:
                    print(foggedBoard[i][j], terminator: " ")
                }
            }
            print("")
        }
    }
    
    func reveal(x: Int, y: Int) -> GameState {
        guard x >= 0 && x < row && y >= 0 && y < column else { return .error }
        
        var position = board[x][y]
        
        guard position > -1 else { return .lose }
        
        if position == 0 {
            findNumber(x: x, y: y)
        }
        
        foggedBoard[x][y] = position
        printBoard()
        
        if checkWinCondition() {
            return .win
        }
        
        return .playing(number: position)
    }
}

final class Minesweeper {
    // MARK: - Private properties
    private var board: Board
    
    // MARK: - Properties
    var state: GameState
    
    init(board: Board = Board(), state: GameState = .idle) {
        self.board = board
        self.state = state
    }
    
    // MARK: - Methods
    
    func startGame() {
        board.startBoard()
        board.printBoard()
    }
    
    func reveal(x: Int, y: Int) {
        let state = board.reveal(x: x, y: y)
        self.state = state
        switch state {
        case .win:
            print("You won")
        case .lose:
            print("You lost")
        case .playing(let number):
            print(number)
        case .error:
            print("Error")
        case .idle:
            break
        }
    }
    
    func gameIsValid() -> Bool {
        switch state {
        case .win, .lose:
            return false
        case .idle, .playing, .error:
            return true
        }
    }
}

enum GameState {
    case idle, win, lose, playing(number: Int), error
}

let game = Minesweeper()

game.startGame()

while game.gameIsValid() {
    print("Type the x coordinate: ")
    if let inputX = readLine(), let intX = Int(inputX) {
        print("Type the y coordinate: ")
        if let inputY = readLine(), let intY = Int(inputY) {
            game.reveal(x: intX, y: intY)
        }
    }
}

