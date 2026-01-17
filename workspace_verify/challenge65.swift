// Challenge 65: compactMap
// Clean up optional readings.

let readings: [Int?] = [1200, nil, 1500, nil, 1600]

let cleaned = readings.compactMap { $0 }
print(cleaned)
// TODO: Print the cleaned array