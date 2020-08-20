import Foundation
import UIKit
import MultipeerConnectivity

public class UserDefaultsExplorerPlugin: NSObject {
    // MARK: - initializer
    public convenience init(serviceType: String? = nil, userDefaults: UserDefaults = UserDefaults.standard) {
        self.init()
        self.multipeerConnectivityWrapper = .init(serviceType: serviceType ?? Constants.defaultServiceType)
        self.userDefaults = userDefaults
        multipeerConnectivityWrapper.start()
        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification, object: nil, queue: nil) { [weak self] (_) in
            guard let _self = self else { return }
            _self.debounce {
                DispatchQueue.main.async {
                    _self.send()
                }
            }
        }
        multipeerConnectivityWrapper.didReceiveHandler = { [weak self] data in
            guard let _self = self else { return }
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                return
            }
            
            if let sync = json["sync"] as? Bool,
                sync {
                _self.debounce {
                    DispatchQueue.main.async {
                        _self.send()
                    }
                }
            }
            
            if let str = json["data"] as? String,
                let data = str.data(using: .utf8),
                let dic = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] {
                dic.forEach { (key, value) in
                    DispatchQueue.main.async {
                        _self.userDefaults.set(value, forKey: key)
                    }
                }
            }
        }
        send()
    }
    
    // MARK: - private
    private var multipeerConnectivityWrapper: MultipeerConnectivityWrapper!
    private var userDefaults: UserDefaults!
    private let debounce = DispatchQueue.global().debounce(delay: .milliseconds(500))
    private override init() {
        super.init()
    }
    
    private func send() {
        let dic = userDefaults.dictionaryRepresentation()
        let data: [String: Any] = [
            "id": UUID().uuidString,
            "timestamp": Date().timeIntervalSinceReferenceDate,
            "data": dic
        ]
        
        guard JSONSerialization.isValidJSONObject(data),
            let json = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) else {
                return
        }
        multipeerConnectivityWrapper.send(data: json)
    }
}

private struct Constants {
    static let defaultServiceType = "explorer"
}

private enum SessionState: String {
    case notConnected
    case connecting
    case connected
}

private final class MultipeerConnectivityWrapper: NSObject {
    // MARK: - internal
    var didReceiveHandler: ((Data) -> Void)?
    func start() {
        advertiserAssistant.delegate = self
        advertiserAssistant.start()
        
        nearbyServiceBrowser.delegate = self
        nearbyServiceBrowser.startBrowsingForPeers()
        
        session.delegate = self
        restartAdvertising()
    }
    
    func reset() {
        restartAdvertising()
        stop()
        start()
    }
    
    func stop() {
        advertiserAssistant.delegate = nil
        advertiserAssistant.stop()
        
        nearbyServiceBrowser.delegate = nil
        nearbyServiceBrowser.startBrowsingForPeers()
        
        disconnect()
    }
    
    func disconnect() {
        session.delegate = nil
        session.disconnect()
    }
    
    func stopAdvertising() {
        nearbyServiceAdvertiser.delegate = nil
        nearbyServiceAdvertiser.stopAdvertisingPeer()
    }
    
    func restartAdvertising() {
        stopAdvertising()
        nearbyServiceAdvertiser.delegate = self
        nearbyServiceAdvertiser.startAdvertisingPeer()
    }
    
    func send(data: Data) {
        if session.connectedPeers.isEmpty {
            pendingData.append(data)
            return
        }
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            pendingData = pendingData.filter({ $0 != data })
        } catch {
            
        }
    }
    
    // MARK: - initializer
    private override init() {
        peerID = .init(displayName: UIDevice.current.name)
        super.init()
    }
    
    convenience init(serviceType: String) {
        self.init()
        setup(serviceType: serviceType)
    }
    
    func setup(serviceType: String) {
        nearbyServiceBrowser = .init(peer: peerID,
                                     serviceType: serviceType)
        session = .init(peer: peerID)
        advertiserAssistant = .init(serviceType: serviceType,
                                    discoveryInfo: nil,
                                    session: session)
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID,
                                                            discoveryInfo: nil,
                                                            serviceType: serviceType)
        session.delegate = self
        start()
    }
    
    // MARK: - private
    private var peerID: MCPeerID
    private var nearbyServiceBrowser: MCNearbyServiceBrowser!
    private var session: MCSession!
    private var advertiserAssistant: MCAdvertiserAssistant!
    private var nearbyServiceAdvertiser: MCNearbyServiceAdvertiser!
    private(set) var state: SessionState = .notConnected
    private var pendingData: [Data] = []
}

extension MultipeerConnectivityWrapper: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            if state == .connected {
                restartAdvertising()
            }
            self.state = .notConnected
        case .connecting:
            self.state = .connecting
        case .connected:
            if state != .connected {
                stopAdvertising()
            }
            if !session.connectedPeers.isEmpty {
                pendingData.forEach({ send(data: $0) })
            }
            self.state = .connected
        @unknown default:
            fatalError("no support")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            self?.didReceiveHandler?(data)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
}

extension MultipeerConnectivityWrapper: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        let session = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 0)
        self.session = session
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
    }
}

extension MultipeerConnectivityWrapper: MCAdvertiserAssistantDelegate {
    
}

extension MultipeerConnectivityWrapper: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
}
