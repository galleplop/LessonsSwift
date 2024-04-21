import UIKit

//MARK: Strings are not arrays
let name = "Taylor"

for letter in name {
    
    print("Give me a \(letter)!")
}

//Don't work
//print(name[3])

let letter = name[name.index(name.startIndex, offsetBy: 3)]


//Foce solution
extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}

print(name[3])

//But now we have a loop within a loop and it has the potential to be slow!
//Example
for i in 0..<name.count {
    
    print("Give me a \(name[i])")
}

//it’s always better to use someString.isEmpty rather than someString.count == 0 if you’re looking for an empty string.


