import SwiftUI

struct UserDefaultsListView: View {
    @EnvironmentObject
    var viewModel: AnyViewModel<UserDefaultsListViewModel.State, UserDefaultsListViewModel.Input>
    
    var body: some View {
        NavigationView {
            List(viewModel.state.viewModels) { viewModel in
                NavigationLink(destination: UserDefaultsDetailView().environmentObject(viewModel)) {
                    UserDefaultsDetailCell(viewModel: viewModel)
                }
            }
            .navigationBarTitle(viewModel.state.connectState.rawValue)
            .navigationBarItems(trailing:
                HStack {
                    Button(action: {
                        self.viewModel.trigger(.reconnect)
                    }) {
                        Text("Reconnect")
                    }
                    .padding(5)
                    Button(action: {
                        self.viewModel.trigger(.sync)
                    }) {
                        Text("Sync")
                    }
                    .padding(5)
                    Button(action: {
                        self.viewModel.trigger(.trash)
                    }) {
                        Image(systemName: "trash")
                            .resizable()
                            .frame(width: 20.0, height: 20.0, alignment: .center)
                            .font(Font.system(.title))
                    }.padding(5)
                }
            )
        }
    }
}

//struct UserDefaultsListContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserDefaultsListContentView()
//    }
//}
