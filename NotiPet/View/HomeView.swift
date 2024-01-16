import SwiftUI

struct HomeView: View {
    @StateObject var homeVM = HomeViewModel()
    @State private var isNotiAddPresented: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                PetProfileView(petProfileUIImage: $homeVM.petProfileUIImage, petName: $homeVM.petName, birthDate: $homeVM.birthDate, sex: $homeVM.sex)
                
                ForEach(0...20, id: \.self) { num in
                    Text("\(num)")
                }
            }
            .listStyle(.plain)
            
            FloatingButton(isNotiAddPresented: $isNotiAddPresented)
        }
    }
}

#Preview {
    HomeView()
}
