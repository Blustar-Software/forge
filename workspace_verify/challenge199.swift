struct Grid {
    let values: [[Int]]
    subscript(_ row: Int, _ col: Int) -> Int {
        return values[row][col]
    }
}

let grid = Grid(values: [[1, 2], [4, 5]])
print(grid[1, 0])