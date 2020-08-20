import SwiftUI

struct UserDefaultsDetailView: View {
    @EnvironmentObject
    var viewModel: AnyViewModel<UserDefaultsDetailCellViewModel.State, UserDefaultsDetailCellViewModel.Input>
    @State
    private var showingAlert = false
    @State
    private var showingModal = false
    @State
    private var showActivityView = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                Text(self.viewModel.state.xml)
                    .padding(5)
                    .onTapGesture {
                        self.showingModal.toggle()
                }.onLongPressGesture(minimumDuration: 0.1) {
                    self.showingAlert.toggle()
                    PasteboardWrapper.default.copy(self.viewModel.state.xml)
                }
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Copy"),
                  message: Text("Copied"),
                  dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showingModal, content: {
            UserDefaultsEditView(closeHandler: {
                self.showingModal.toggle()
            }, saveHandler: { (text) in
                self.showingModal.toggle()
                self.viewModel.trigger(.updateXML(text))
            }, text: self.viewModel.state.xml)
        }).navigationBarTitle(viewModel.state.object.id)
            .navigationBarItems(trailing:
                HStack {
                    Button(action: {
                        self.showActivityView.toggle()
                    }) {
                        Text("􀈂")
                    }.sheet(isPresented: self.$showActivityView) {
                        ActivityView(
                            activityItems: [self.viewModel.state.xml],
                            applicationActivities: nil
                        )
                    }
                }
        )
    }
}

//struct UserDefaultsDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserDefaultsDetailView()
//    }
//}
