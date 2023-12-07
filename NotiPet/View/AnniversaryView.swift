import SwiftUI

struct AnniversaryView: View {
    @Binding var dDay: String
    @Binding var content: String
    
    var body: some View {
        HStack {
            Text(dDay)
            Text(content)
        }
    }
}

//#Preview {
//    SpecialAnniversaryView(dDay: <#Binding<Int>#>, content: <#Binding<String>#>)
//}
