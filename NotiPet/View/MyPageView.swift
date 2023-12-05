import SwiftUI

struct MyPageView: View {
    @State var isPresented: Bool = false
    @StateObject var myPageViewModel = MyPageViewModel()
    @State private var items = ["Item 1", "Item 2", "Item 3", "Item 4"]
    var body: some View {
        List {
            VStack {
                HStack {
                    Image(uiImage: myPageViewModel.petProfileUIImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill )
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        .frame(width: 100, height: 100)
                    VStack(alignment: .leading) {
                        HStack {
                            Image(uiImage: UIImage(named: myPageViewModel.sex == "남아" ? "Male" : "Female")!)
                            Text(myPageViewModel.petName)
                                .lineLimit(1)
                            Spacer()
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
                        Text("함께한지 \(myPageViewModel.birthDate.dayConvertDate())일")
                            .lineLimit(1)
                        Text("\(myPageViewModel.species), \(myPageViewModel.weight)kg")
                            .lineLimit(1)
                    }
                }
            }
            Spacer()
                .frame(height: 150)
            
            // 특별한 기념일
            HStack {
                Spacer()
                Text("\(myPageViewModel.petName)의 특별한 기념일")
                    .lineLimit(1)
                Spacer()
                Button(action: {
                    
                }, label: {
                    Image(systemName: "plus")
                })
            }
            ForEach(items, id: \.self) { item in
                Text(item)
                    .frame(height: 200)
            }
            .onDelete(perform: delete)
            
            
        }
        .listStyle(.plain)
        
    }
    
    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
}

#Preview {
    MyPageView()
}
