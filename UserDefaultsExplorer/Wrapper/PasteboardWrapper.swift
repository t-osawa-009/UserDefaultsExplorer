import Foundation
import UIKit

final class PasteboardWrapper {
    // MARK: - internal
    static let `default` = PasteboardWrapper()
    func copy(_ text: String) {
        UIPasteboard.general.string = text
    }
    
    // MARK: - initializer
    private init() { }
}
