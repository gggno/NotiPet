import SwiftUI

struct PetInfoView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Text("우리 아이 정보")
            Spacer()
            Button(action: {
                isPresented.toggle()
            }, label: {
                Text("확인")
            })
            .padding(.bottom, 70)
        }
    }
}
