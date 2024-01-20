import SwiftUI
import Combine

struct NotiView: View {
    @StateObject var notiVM = NotiViewModel()
    @State var showDeleteAlert: Bool = false
    @State var modifyPresented: Bool = false
    
    @State var deleteData: NotiData? = nil
    @State var modifyData: NotiData? = nil
    
    var body: some View {
        if notiVM.notiDatas.isEmpty {
            NoDataView()
        } else {
            List {
                ForEach(notiVM.notiDatas, id: \.self) { notiData in
                    NotiListView(notiData: notiData)
                        .swipeActions() {
                            Button() {
                                showDeleteAlert.toggle()
                                deleteData = notiData
                            } label: {
                                Text("삭제")
                            }
                            .tint(.red)
                            
                            Button {
                                modifyData = notiData
                                modifyPresented.toggle()
                            } label: {
                                Text("수정")
                            }
                            .tint(.yellow)
                        }
                        .fullScreenCover(isPresented: $modifyPresented) {
                            NotiAddView(isNotiAddPresented: $modifyPresented, modifyData: $modifyData)
                        }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 8)
                        .background(.clear)
                        .foregroundColor(.blue)
                        .padding(
                            EdgeInsets(
                                top: 2,
                                leading: 10,
                                bottom: 2,
                                trailing: 10
                            )
                        )
                )
            }
            .listStyle(.plain)
            .alert("삭제 알림", isPresented: $showDeleteAlert) {
                Button("삭제", role: .destructive) {
                    withAnimation {
                        if let deleteData = deleteData {
                            notiVM.deleteNotiData(notiData: deleteData)
                        }
                    }
                }
                Button("취소", role: .cancel) {
                }
            }
        }
    }
}

#Preview {
    NotiView()
}
