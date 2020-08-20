import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    #if targetEnvironment(macCatalyst)
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        builder.remove(menu: .file)
        builder.remove(menu: .format)
        builder.remove(menu: .help)
        builder.remove(menu: .services)
        builder.remove(menu: .view)
        let refreshCommand = UIKeyCommand(input: "E", modifierFlags: [.command], action: #selector(handleEditMenu(_:)))
        refreshCommand.title = "Edit ServiceType"
        let reloadDataMenu = UIMenu(title: "Edit ServiceType", image: nil, identifier: UIMenu.Identifier("editServiceType"), options: .displayInline, children: [refreshCommand])
        builder.insertChild(reloadDataMenu, atStartOfMenu: .edit)
    }
    
    @objc private func handleEditMenu(_ command: UIKeyCommand) {
        var uiTextField = UITextField()
        let ac = UIAlertController(title: "Edit the serviceType",
                                   message: "Up to 15 characters",
                                   preferredStyle: .alert)
        let aa = UIAlertAction(title: "OK", style: .default) { (action) in
            let text = (uiTextField.text ?? "").removeSpecialCharacters()
            UserDefaultsWrapper.default.serviceType = String(text.prefix(15))
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .removeWhitespace()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addTextField { (textField) in
            textField.text = UserDefaultsWrapper.default.serviceType
            textField.keyboardType = .emailAddress
            uiTextField = textField
        }
        ac.addAction(aa)
        ac.addAction(cancel)
        let sceneDelegate = UIApplication.shared.connectedScenes
            .first!.delegate as! SceneDelegate
        sceneDelegate.window!.rootViewController?.present(ac, animated: true, completion: nil)
    }
    #endif
}

