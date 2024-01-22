import SwiftUI

struct InputTextFieldView: View {
    var theme: String
    @Binding var content: String
    @Binding var message: String
    var lineLimit: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(theme)
                    .font(.body)
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
            TextField(
                "",
                text: $content,
                axis: .vertical
            )
            .lineLimit(lineLimit)
            .textInputAutocapitalization(.never)
            .textFieldStyle(.roundedBorder)
        }
    }
}

//#Preview {
//    InputTextFieldView(theme: <#Binding<String>#>, content: <#Binding<String>#>, message: <#Binding<String>#>, lineLimit: <#Binding<Int>#>)
//}
