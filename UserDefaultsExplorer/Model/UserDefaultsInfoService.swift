import Foundation

protocol InfoService {
    func fetch() -> [PeerObject]
    func reconnect()
    func removeAll()
}

final class UserDefaultsInfoService: InfoService {
    // MARK: - internal
    func fetch() -> [PeerObject] {
        return array
    }
    
    func removeAll() {
        array.removeAll(keepingCapacity: true)
    }
    
    func reconnect() {
        multipeerConnectivityWrapper.setup(serviceType: UserDefaultsWrapper.default.serviceType)
        multipeerConnectivityWrapper.reset()
    }
    
    func update(peerObject: PeerObject) {
        guard let index = array.firstIndex(where: {$0.id == peerObject.id }) else {
            return
        }
        array[index] = peerObject
        didItemChange?()
    }
    
    func sendSync() {
        var dic: [String: Any] = [:]
        dic["sync"] = true
        if let data = try? JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted) {
            multipeerConnectivityWrapper.send(data: data)
        }
    }
    
    func send(data: Data) {
        var dic: [String: Any] = [:]
        dic["data"] = String(data: data, encoding: .utf8)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            multipeerConnectivityWrapper.send(data: jsonData)
        } catch {
            logMessage(message: error.localizedDescription)
        }
    }
    
    var didItemChange: (() -> Void)?
    var didStateChange: (() -> Void)?
    
    // MARK: - initializer
    init(multipeerConnectivityWrapper: MultipeerConnectivityWrapper) {
        self.multipeerConnectivityWrapper = multipeerConnectivityWrapper
        
        multipeerConnectivityWrapper.didReceiveDataHandler = { [weak self] object in
            self?.array.append(object)
            self?.array.sort(by: { $0.date > $1.date })
            self?.didItemChange?()
        }
        
        multipeerConnectivityWrapper.sessionDidChangeHandler = { [weak self] state, object in
            self?.state = state
            self?.didStateChange?()
        }
    }
    
    // MARK: - private
    private var multipeerConnectivityWrapper: MultipeerConnectivityWrapper
    private(set) var array: [PeerObject] = []
    private(set) var state: SessionState = .notConnected
}
