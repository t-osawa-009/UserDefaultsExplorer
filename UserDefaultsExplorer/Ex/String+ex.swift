import Foundation

extension String {    
    func removeSpecialCharacters() -> String {
        let okayChars = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890-&_")
        return String(unicodeScalars.filter { okayChars.contains($0) && !$0.properties.isEmoji })
    }
    
    func removeWhitespace() -> String {
        return replacingOccurrences(of: " ", with: "")
    }
}
