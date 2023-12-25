import SwiftUI

struct NotiAddView: View {
    @Binding var isNotiAddPresented: Bool
    @StateObject var notiVM: NotiAddViewModel = NotiAddViewModel()
    
    var body: some View {
        NavigationView {
            List {
                VStack {
                    InputTextFieldView(theme: "내용", content: $notiVM.notiContent, message: $notiVM.notiContentMessage, lineLimit: 2)
                }
            }
            .navigationTitle("알림 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        isNotiAddPresented.toggle()
                    }, label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                    })
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        
                    }, label: {
                        Text("완료")
                    })
                }
            }
        }
        .listStyle(.plain)
        .onAppear(perform : UIApplication.shared.hideKeyboard)
        .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
    }
}

//#Preview {
//    NotiAddView()
//}
