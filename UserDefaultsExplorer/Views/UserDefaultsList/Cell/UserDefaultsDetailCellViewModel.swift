import Foundation

final class UserDefaultsDetailCellViewModel: ViewModel {
    struct State: Identifiable {
        var id = UUID()
        var object: PeerObject
        var xml: String
    }
    
    enum Input {
        case updateXML(String)
    }
    
    @Published
    private(set) var state: State
    private var service: UserDefaultsInfoService
    init(service: UserDefaultsInfoService, object: PeerObject) {
        self.service = service
        let xml: String = {
            if let plistData = try? PropertyListSerialization.data(fromPropertyList: object.dic, format: .xml, options: 0) {
                return String(data: plistData, encoding: .utf8) ?? ""
            } else {
                return ""
            }
        }()
        self.state = .init(object: object, xml: xml)
    }
    
    func trigger(_ input: UserDefaultsDetailCellViewModel.Input) {
        switch input {
        case .updateXML(let text):
            self.state.xml = text
            if let data = text.data(using: .utf8) {
                self.state.object = .init(data: data, peerID: self.state.object.peerID)
                service.update(peerObject: self.state.object)
                service.send(data: data)
            }
        }
    }
}
