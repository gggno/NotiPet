import SwiftUI

struct MyPageView: View {
    @State var isPresented: Bool = false
    @State var isAnniViewPresented: Bool = false
    @StateObject var myPageVM = MyPageViewModel()
    
    var body: some View {
        List {
            VStack {
                HStack {
                    if let image = myPageVM.petProfileUIImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill )
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            .frame(width: 100, height: 100)
                    } else {
                        Circle()
                            .fill()
                            .overlay(
                                Text("이미지 추가")
                                    .foregroundColor(.blue)
                            )
                            .frame(width: 100, height: 100)
                    }
                    VStack(alignment: .leading) {
                        HStack {
                            Image(uiImage: UIImage(named: myPageVM.sex == "남아" ? "Male" : "Female")!)
                            Text(myPageVM.petName)
                                .lineLimit(1)
                            Spacer()
                            Image(systemName: "gearshape.fill")
                                .imageScale(.large)
                                .foregroundColor(.blue)
                                .onTapGesture {
                                    isPresented.toggle()
                                }
                                .fullScreenCover(isPresented: $isPresented, content: {
                                    PetInfoView(isPresented: $isPresented)
                                })
                        }
                        Text("함께한지 \(Int(myPageVM.birthDate.dayConvertDate())! + 1)일")
                            .lineLimit(1)
                        Text("\(myPageVM.species), \(myPageVM.weight)kg")
                            .lineLimit(1)
                    }
                }
            }
            .listRowSeparator(.hidden)
            Spacer()
                .frame(height: 150)
            
            // 특별한 기념일
            HStack {
                Spacer()
                Text("\(myPageVM.petName)의 특별한 기념일")
                    .lineLimit(1)
                
                Spacer()
                Image(systemName: "plus")
                    .onTapGesture {
                        isAnniViewPresented.toggle()
                    }
                    .fullScreenCover(isPresented: $isAnniViewPresented) {
                        AnniversaryAddView(isAnniViewPresented: $isAnniViewPresented)
                    }
            }
            .listRowSeparator(.hidden)
            
            ForEach(myPageVM.anniversaryDatas, id: \.self) { data in
                HStack {
                    Text(data.dDay)
                    Text(data.content)
                    Spacer()
                    Text(data.dueDate)
                }
            }
            .onDelete(perform: { indexSet in
                myPageVM.deleteRow(indexSet: indexSet)
            })
        }
        .listStyle(.plain)
        .alert(isPresented: $myPageVM.showBirthdayAlert) {
            Alert(title: Text("알림"), message: Text("생일은 삭제할 수 없습니다."), dismissButton: .default(Text("확인")))
        }
        .onAppear {
            NotificationHandler.shered.checkRegisteredNotification()
        }
    }
}

#Preview {
    MyPageView()
}
