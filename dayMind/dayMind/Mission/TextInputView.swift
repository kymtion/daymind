
import SwiftUI

struct TextInputView: View {
    @Binding var textInputPresented: Bool
    @State var storeName: String = ""
    
    var onSave: (String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("저장소 이름을 입력하세요", text: $storeName)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding()
                .border(Color.gray, width: 0.5)
            Button("확인") {
                onSave(storeName)
                textInputPresented = false
            }
        }
        .padding()
    }
}
struct TextInputView_Previews: PreviewProvider {
    @State static var textInputPresented = true
    static var previews: some View {
            TextInputView(textInputPresented: $textInputPresented, onSave: { text in
                print("Text input completed with: \(text)")
            })
        }
    }
