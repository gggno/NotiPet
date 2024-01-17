import SwiftUI

struct SelectedNotiView: View {
    @Binding var selectedDate: Date
    @Binding var selectedNotiDatas: [NotiData]
    
    var body: some View {
        VStack(alignment: .center) {
            Text(selectedDate.convertDatePlusDay())
            
            ForEach(selectedNotiDatas, id: \.self) { notiData in
                Text("\(notiData.content)")
            }
        }
    }
}

