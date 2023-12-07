import SwiftUI

struct MyPageView: View {
    @State var isPresented: Bool = false
    @StateObject var myPageVM = MyPageViewModel()
    
    var body: some View {
        List {
            VStack {
                HStack {
                    Image(uiImage: myPageVM.petProfileUIImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill )
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        .frame(width: 100, height: 100)
                    VStack(alignment: .leading) {
                        HStack {
                            Image(uiImage: UIImage(named: myPageVM.sex == "남아" ? "Male" : "Female")!)
                            Text(myPageVM.petName)
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
                        Text("함께한지 \(myPageVM.birthDate.dayConvertDate())일")
                            .lineLimit(1)
                        Text("\(myPageVM.species), \(myPageVM.weight)kg")
                            .lineLimit(1)
                    }
                }
            }
            Spacer()
                .frame(height: 150)
            
            // 특별한 기념일
            HStack {
                Spacer()
                Text("\(myPageVM.petName)의 특별한 기념일")
                    .lineLimit(1)
                Spacer()
                Button(action: {
                    // 특별한 기념일 뷰 만들어서 이동 로직 구현하기
                }, label: {
                    Image(systemName: "plus")
                })
            }
            ForEach(myPageVM.anniversaryDatas, id: \.self) { data in
                // 특별한 기념일 뷰(간략한 버전) 만들어서 Text 대신 넣어서 구현하기
                HStack {
                    Text(data.dDay)
                    Text(data.content)
                }
            }
            
        }
        .listStyle(.plain)
    }
}

#Preview {
    MyPageView()
}
