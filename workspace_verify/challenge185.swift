import Foundation

let numbers = [1, 2, 3]
let doubled = numbers.lazy.map { $0 * 2 }
print(Array(doubled))