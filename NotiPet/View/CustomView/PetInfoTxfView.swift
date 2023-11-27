import SwiftUI

struct PetInfoTxfView: View {
    @State var content: String = ""
    @Binding var title: String
    @Binding var validate: String
    @Binding var inputCount: Int
    
   
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                Text(validate)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .opacity(content.count >= inputCount ? 0.0 : 1.0) // 길이에 따라 비활성화
            }
            TextField(
                "",
                text: $content
            )
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .border(.black)   
        }
    }
}

#Preview {
    PetInfoTxfView(title: .constant("이름"), validate: .constant("한 글자 이상 입력하세요"), inputCount: .constant(1))
}
