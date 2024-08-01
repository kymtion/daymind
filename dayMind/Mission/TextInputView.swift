
import SwiftUI

struct TextInputView: View {
    @Binding var textInputPresented: Bool
    @State var storeName: String = ""
    
    var onSave: (String) -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Text("앱 허용 리스트 이름")
                .font(.system(size: 25))
            
            TextField("리스트 이름을 입력하세요. ex) 업무용", text: $storeName)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding()
                .border(Color.gray, width: 0.5)
            
            
            HStack(spacing: 10) {
                Button {
                    textInputPresented = false
                } label: {
                    Text("취소")
                        .padding(10)
                        .font(.system(size: 20, weight: .bold))
                        .frame(width: UIScreen.main.bounds.width * 0.3)
                        .background(Color.gray.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    
                }
                Button {
                    onSave(storeName)
                    textInputPresented = false
                } label: {
                    Text("확인")
                        .padding(10)
                        .font(.system(size: 20, weight: .bold))
                        .frame(width: UIScreen.main.bounds.width * 0.3)
                        .background(Color.blue.opacity(storeName.isEmpty ? 0.5 : 0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        

                }
                .disabled(storeName.isEmpty)
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
