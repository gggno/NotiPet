import SwiftUI
import Combine
import RealmSwift

struct NotiView: View {
    @StateObject var notiVM = NotiViewModel()
    
    var body: some View {
        if notiVM.notiDatas.isEmpty {
            NoDataView()
        } else {
            List {
                ForEach(notiVM.notiDatas, id: \.self) { notiData in
                    NotiListView(notiData: notiData)
                        .listRowSeparator(.hidden)
                        .border(Color.gray, width: 1)
                }
                
                .onDelete{ index in
                    
                }
            }
            
            .listStyle(.plain)
        }
        
    }
}

#Preview {
    NotiView()
}
