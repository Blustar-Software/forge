infix operator +++: AdditionPrecedence

func +++ (lhs: Int, rhs: Int) -> Int {
    return lhs + rhs
}

print(3 +++ 4)