import SwiftUI

struct HomeView: View {
    @StateObject var homeVM = HomeViewModel()
    @State private var isNotiAddPresented: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                VStack(alignment: .leading, spacing: 25) {
                    PetProfileView(petProfileUIImage: $homeVM.petProfileUIImage, petName: $homeVM.petName, birthDate: $homeVM.birthDate, sex: $homeVM.sex)
                    HomeDatePicker(selectedDate: $homeVM.selectedDate)
                    SelectedNotiView(selectedDate: $homeVM.selectedDate, selectedNotiDatas: $homeVM.selectedNotiDatas)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            
            FloatingButton(isNotiAddPresented: $isNotiAddPresented)
        }
    }
}
