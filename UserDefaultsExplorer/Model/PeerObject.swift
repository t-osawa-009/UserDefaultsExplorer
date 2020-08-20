import Foundation
import MultipeerConnectivity

private var formatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.formatterBehavior = .behavior10_4
    dateFormatter.dateFormat = "HH:mm:ss.SSS"
    return dateFormatter
}()

struct PeerObject {
    let id: String
    let date: Date
    let data: Data
    let dateString: String
    let dic: [String: Any]
    let peerID: MCPeerID
    init(data: Data, peerID: MCPeerID) {
        self.data = data
        self.peerID = peerID
        if let dic = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
            self.dic = dic["data"] as? [String: Any] ?? [:]
            if let time = dic["timestamp"] as? TimeInterval {
                let date = Date(timeIntervalSinceReferenceDate: time)
                self.date = date
            } else {
                date = Date()
            }
            if let _id = dic["id"] as? String {
                self.id = _id
            } else {
                self.id = "unknown"
            }
        } else {
            self.dic = [:]
            date = Date()
            self.id = "unknown"
        }
        self.dateString = formatter.string(from: date)
    }
}

