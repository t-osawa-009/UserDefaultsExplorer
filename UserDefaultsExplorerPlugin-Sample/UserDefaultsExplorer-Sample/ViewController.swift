import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(1, forKey: "1")
        UserDefaults.standard.set(2, forKey: "2")
        UserDefaults.standard.set(3, forKey: "3")
        UserDefaults.standard.set(4, forKey: "4")
        UserDefaults.standard.set(5, forKey: "5")
        UserDefaults.standard.set(6, forKey: "6")
    }
    
    @IBAction func reconnectTapped(_ sender: Any) {
        (UIApplication.shared.delegate as! AppDelegate).userDefaultsExplorerPlugin.reconnect()
    }
}

