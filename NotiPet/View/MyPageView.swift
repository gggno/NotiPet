import SwiftUI

struct MyPageView: View {
    @State var isPresented: Bool = false
    
    var body: some View {
        VStack {
            HStack {
            
            }
            Text("MyPageView")
            Button(action: {
                isPresented.toggle()
            }) {
                Image(systemName: "gearshape.fill")
                    .imageScale(.large)
                    .foregroundColor(.blue)
            }
            .fullScreenCover(isPresented: $isPresented, content: {
                PetInfoView(isPresented: $isPresented)
            })
        }
        
    }
}

#Preview {
    MyPageView()
}
