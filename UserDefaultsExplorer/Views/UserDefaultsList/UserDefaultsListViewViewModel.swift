import Foundation

final class UserDefaultsListViewModel: ViewModel {
    struct State {
        var viewModels: [AnyViewModel<UserDefaultsDetailCellViewModel.State, UserDefaultsDetailCellViewModel.Input>]
        var connectState: SessionState = .notConnected
    }
    
    enum Input {
        case trash
        case reload
        case refreshState
        case sync
        case reconnect
    }
    // MARK: - internal
    @Published
    var state: UserDefaultsListViewModel.State
    
    init(service: UserDefaultsInfoService) {
        self.service = service
        let viewModels = service.fetch().map {
            AnyViewModel(UserDefaultsDetailCellViewModel(service: service, object: $0))
        }
        
        self.state = State(viewModels: viewModels)
        setup()
    }
    
    func trigger(_ input: UserDefaultsListViewModel.Input) {
        switch input {
        case .trash:
            service.removeAll()
            self.state.viewModels = fetch()
        case .reload:
            self.state.viewModels = fetch()
        case .refreshState:
            self.state.connectState = service.state
        case .sync:
            service.sendSync()
        case .reconnect:
            service.reconnect()
        }
    }
    
    // MARK: - private
    private let service: UserDefaultsInfoService
    private func fetch() -> [AnyViewModel<UserDefaultsDetailCellViewModel.State, UserDefaultsDetailCellViewModel.Input>] {
        service.fetch().map {
            AnyViewModel(UserDefaultsDetailCellViewModel(service: service, object: $0))
        }
    }
    
    private func setup() {
        service.didItemChange = { [weak self] in
            self?.trigger(.reload)
        }
        
        service.didStateChange = { [weak self] in
            self?.trigger(.refreshState)
        }
    }
}
