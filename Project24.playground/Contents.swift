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

//MARK: Working with strings


let password = "123456"
password.hasPrefix("123")
password.hasSuffix("456")

extension String {
    
    func deletingPrefix(_ prefix: String) -> String {
        
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    func deletingSuffix(_ suffix: String) -> String {
        
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
}

let testDeleting = password.deletingPrefix("123").deletingSuffix("456")

//MARK: -

let weather = "it's going to rain"
print(weather.capitalized)

extension String {
    
    var capitalizedFirst: String {
        guard let firstLetter = self.first else { return "" }
        return firstLetter.uppercased() + self.dropFirst()
    }
}

print(weather.capitalizedFirst)

//MARK: -

let input = "Swift is like Objective-C without the C"
input.contains("Swift")

let languages = ["Python", "Ruby", "Swift"]
languages.contains("Swift")

languages.contains(where: input.contains) //Lika a map function. every elementy will run the closure input.contains, when one of these gets true it stops there.

