import Foundation
public struct UserDefaultsWrapper {
    public static var `default` = UserDefaultsWrapper()
    @UserDefault("serviceType", defaultValue: "explorer")
    public var serviceType: String
}
