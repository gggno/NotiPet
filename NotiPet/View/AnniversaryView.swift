import SwiftUI

struct AnniversaryView: View {
    @Binding var anniContent: String
    @Binding var anniContentMessage: String
    @Binding var anniDate: String
    
    var body: some View {
        VStack {
            Text("기념일 추가")
            Spacer()
            VStack(alignment: .leading) {
                HStack {
                    Text("내용")
                    Text(anniContentMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
                TextField(
                    "",
                    text: $anniContent
                )
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .border(.black)
            }
            DatePicker_Graphical()
        }
    }
}

//#Preview {
//    SpecialAnniversaryView(dDay: <#Binding<Int>#>, content: <#Binding<String>#>)
//}
