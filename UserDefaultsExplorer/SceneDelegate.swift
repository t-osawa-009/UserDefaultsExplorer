import UIKit
import SwiftUI

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private let multipeerConnectivityWrapper = MultipeerConnectivityWrapper(serviceType: UserDefaultsWrapper.default.serviceType)

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        multipeerConnectivityWrapper.start()
        let service = UserDefaultsInfoService(multipeerConnectivityWrapper: multipeerConnectivityWrapper)
        let viewModel = AnyViewModel(UserDefaultsListViewModel(service: service))
        let contentView = UserDefaultsListView()
            .environmentObject(viewModel)
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

