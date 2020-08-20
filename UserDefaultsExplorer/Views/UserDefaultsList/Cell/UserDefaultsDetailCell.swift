import SwiftUI

struct UserDefaultsDetailCell: View {
    var viewModel: AnyViewModel<UserDefaultsDetailCellViewModel.State, UserDefaultsDetailCellViewModel.Input>
    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.state.object.id)
            Text(viewModel.state.object.peerID.displayName)
            Text(viewModel.state.object.dateString)
        }
    }
}

//struct UserDefaultsDetailCell_Previews: PreviewProvider {
//    static var previews: some View {
//        UserDefaultsDetailCell(
//    }
//}
