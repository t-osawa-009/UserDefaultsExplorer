import SwiftUI

struct MultilineTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var font: UIFont
    
    final class Coordinator: NSObject, UITextViewDelegate {
        private var textView: MultilineTextView
        
        init(_ textView: MultilineTextView) {
            self.textView = textView
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return true
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.textView.text = textView.text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.font = font
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.font = font
    }
}

struct MultilineTextView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State
        var text: String = ""
        @State
        private var font: UIFont = .systemFont(ofSize: 30)
        var body: some View {
            MultilineTextView(text: $text, font: $font)
        }
    }
}
