// Challenge 13: Logical Operators
// Use &&, ||, and ! with a simple checklist

let heatReady = true
let toolsReady = false

let ready = heatReady && toolsReady
let partialReady = heatReady || toolsReady
let notReady = !ready

print(ready)
print(partialReady)
print(notReady)
// TODO: Create a constant 'partialReady' that is true if EITHER is ready
// TODO: Create a constant 'notReady' that is the opposite of ready
// TODO: Print ready, partialReady, and notReady (in that order)