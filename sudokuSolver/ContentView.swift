import SwiftUI

struct ContentView: View {
    // Define a 9x9 grid for the Sudoku board
    @State private var sudokuGrid: [[String]] = Array(repeating: Array(repeating: "", count: 9), count: 9)
    @State private var showPopup = false
    @State private var popupMessage = ""

    var body: some View {
        VStack {
            VStack(spacing: 0) {
                ForEach(0..<9, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<9, id: \.self) { col in
                            ZStack {
                                // Alternate background color for 3x3 sections
                                if (row / 3 + col / 3) % 2 == 0 {
                                    Color(.systemGray6)
                                } else {
                                    Color.white
                                }

                                // Editable TextField for all cells
                                TextField("", text: Binding(
                                    get: { sudokuGrid[row][col] },
                                    set: { newValue in
                                        if !newValue.isEmpty {
                                            if newValue.count > 1 || !isValidInput(newValue, row, col) {
                                                popupMessage = "Invalid input!"
                                                showPopup = true
                                            } else {
                                                sudokuGrid[row][col] = newValue
                                            }
                                        } else {
                                            sudokuGrid[row][col] = newValue
                                        }
                                    }
                                ))
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .frame(width: 35, height: 35)
                                .background(Color.clear)
                            }
                            .overlay(
                                Rectangle()
                                    .stroke(Color.black, lineWidth: (row % 3 == 2 && row != 8 || col % 3 == 2 && col != 8) ? 2 : 1)
                            )
                        }
                    }
                }
            }
            .frame(width: 320, height: 320) // Set a fixed frame for the grid
            .aspectRatio(1, contentMode: .fit) // Maintain a 1:1 aspect ratio to keep it square
            .padding(2)

            Button(action: {
                if solveSudoku(grid: &sudokuGrid) {
                    print("Solved successfully")
                } else {
                    popupMessage = "No solution exists!"
                    showPopup = true
                }
            }) {
                Text("Solve")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)

            Button(action: {
                resetGrid()
            }) {
                Text("Reset")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .alert(isPresented: $showPopup) {
            Alert(title: Text("Error"), message: Text(popupMessage), dismissButton: .default(Text("OK")))
        }
    }

    func resetGrid() {
        // Reset all cells to empty
        sudokuGrid = Array(repeating: Array(repeating: "", count: 9), count: 9)
    }

    func solveSudoku(grid: inout [[String]]) -> Bool {
        var board = grid.map { $0.map { Int($0) ?? 0 } }

        if solveSudokuHelper(&board) {
            // Update the grid with the solution
            for i in 0..<9 {
                for j in 0..<9 {
                    grid[i][j] = board[i][j] == 0 ? "" : String(board[i][j])
                }
            }
            return true
        }
        return false
    }

    func solveSudokuHelper(_ board: inout [[Int]]) -> Bool {
        for row in 0..<9 {
            for col in 0..<9 {
                if board[row][col] == 0 { // Empty cell
                    for num in 1...9 {
                        if isValid(board, row, col, num) {
                            board[row][col] = num
                            if solveSudokuHelper(&board) {
                                return true
                            }
                            board[row][col] = 0
                        }
                    }
                    return false
                }
            }
        }
        return true // Solved
    }

    func isValid(_ board: [[Int]], _ row: Int, _ col: Int, _ num: Int) -> Bool {
        for i in 0..<9 {
            if board[row][i] == num || board[i][col] == num || board[row/3*3 + i/3][col/3*3 + i%3] == num {
                return false
            }
        }
        return true
    }

    func isValidInput(_ value: String, _ row: Int, _ col: Int) -> Bool {
        guard let num = Int(value), num > 0 && num <= 9 else {
            return false
        }

        for i in 0..<9 {
            if sudokuGrid[row][i] == value && i != col { return false }
            if sudokuGrid[i][col] == value && i != row { return false }
        }

        let boxRowStart = (row / 3) * 3
        let boxColStart = (col / 3) * 3
        for r in boxRowStart..<boxRowStart+3 {
            for c in boxColStart..<boxColStart+3 {
                if sudokuGrid[r][c] == value && (r != row || c != col) {
                    return false
                }
            }
        }
        return true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
