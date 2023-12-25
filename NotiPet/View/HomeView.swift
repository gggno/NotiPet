import SwiftUI

struct HomeView: View {
    @State private var isNotiAddPresented: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                ForEach(0...20, id: \.self) { num in
                    Text("\(num)")
                    
                }
            }
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
                NotiAddView(isNotiAddPresented: $isNotiAddPresented)
            })
        }
    }
}

#Preview {
    HomeView()
}
