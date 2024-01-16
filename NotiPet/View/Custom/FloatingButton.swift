import SwiftUI

struct FloatingButton: View {
    @Binding var isNotiAddPresented: Bool
    @State var tempModifyData: NotiData? = nil
    
    var body: some View {
        Button(action: {
            isNotiAddPresented.toggle()
        }, label: {
            Image(systemName: "plus")
                .resizable()
                .renderingMode(.template)
                .frame(width: 28, height: 28)
                .padding()
        })
        .background(Color(.systemBlue))
        .foregroundColor(.white)
        .clipShape(Circle())
        .padding()
        .fullScreenCover(isPresented: $isNotiAddPresented, content: {
            NotiAddView(isNotiAddPresented: $isNotiAddPresented, modifyData: $tempModifyData)
        })
    }
}

