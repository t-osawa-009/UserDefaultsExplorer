import SwiftUI

struct UserDefaultsEditView: View {
    var closeHandler: (() -> ())?
    var saveHandler: ((String) -> ())?
    @State
    var text: String
    @State
    private var font: UIFont = .systemFont(ofSize: 25)
    @State
    private var showingAlert = false
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.closeHandler?()
                }) {
                    Text("􀆄").font(.system(size: 20))
                }.padding(5)
                Spacer()
                Button(action: {
                    if self.font.pointSize > 10 {
                        self.font = UIFont.systemFont(ofSize: self.font.pointSize - 1)
                    }
                }) {
                    Text("􀅽").font(.system(size: 20))
                }.padding(5)
                Button(action: {
                    if self.font.pointSize < 50 {
                        self.font = UIFont.systemFont(ofSize: self.font.pointSize + 1)
                    }
                }) {
                    Text("􀅼").font(.system(size: 20))
                }.padding(5)
                Button(action: {
                    self.showingAlert.toggle()
                    PasteboardWrapper.default.copy(self.text)
                }) {
                    Text("copy").font(.system(size: 20))
                }.padding(5)
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("Copy"),
                              message: Text("Copied"),
                              dismissButton: .default(Text("OK")))
                }
                Button(action: {
                    self.saveHandler?(self.text)
                }) {
                    Text("save").font(.system(size: 20))
                }.padding(5)
            }
            MultilineTextView(text: $text, font: $font)
        }
    }
}

struct UserDefaultsEditView_Previews: PreviewProvider {
    static var previews: some View {
        UserDefaultsEditView(text: "hoheohoeteoteot")
    }
}
