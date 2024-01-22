import SwiftUI

struct MyPageView: View {
    @State var isPresented: Bool = false
    @State var isAnniViewPresented: Bool = false
    @StateObject var myPageVM = MyPageViewModel()
    
    var body: some View {
        List {
            VStack {
                HStack(spacing: 15) {
                    if let image = myPageVM.petProfileUIImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill )
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            .frame(width: 100, height: 100)
                    } else {
                        Image("PetBasicProfile")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            .frame(width: 100, height: 100)
                    }
                    VStack(alignment: .leading) {
                        HStack {
                            Image(uiImage: UIImage(named: myPageVM.sex == "남아" ? "Male" : "Female")!)
                                .cornerRadius(5)
                            Text(myPageVM.petName)
                                .lineLimit(1)
                                .font(.system(size: 20, weight: .bold))
                            Spacer()
                            Image(systemName: "gearshape.fill")
                                .imageScale(.large)
                                .foregroundStyle(Color("PeachColor"))
                                .onTapGesture {
                                    isPresented.toggle()
                                }
                                .fullScreenCover(isPresented: $isPresented, content: {
                                    PetInfoView(isPresented: $isPresented)
                                        .background(Color("BlueColor"))
                                })
                        }
                        Text("함께한지 \((Int(myPageVM.birthDate.dayConvertDate()) ?? 0) + 1)일")
                            .lineLimit(1)
                            .font(.system(size: 15, weight: .regular))
                        Text("\(myPageVM.species), \(myPageVM.weight)kg")
                            .lineLimit(1)
                            .font(.system(size: 15, weight: .regular))
                    }
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            Spacer()
                .frame(height: 150)
                .listRowBackground(Color.clear)
            Group {
                // 특별한 기념일
                HStack {
                    Spacer()
                    Text("\(myPageVM.petName)의 특별한 기념일")
                        .lineLimit(1)
                        .font(.system(size: 15, weight: .semibold))
                    
                    Spacer()
                    Image(systemName: "plus")
                        .foregroundStyle(Color("PeachColor"))
                        .onTapGesture {
                            isAnniViewPresented.toggle()
                        }
                        .fullScreenCover(isPresented: $isAnniViewPresented) {
                            AnniversaryAddView(isAnniViewPresented: $isAnniViewPresented)
                        }
                }
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                
                ForEach(myPageVM.anniversaryDatas, id: \.self) { data in
                    HStack {
                        Text(data.dDay)
                        Text(data.content)
                        Spacer()
                        Text(data.dueDate)
                    }
                    .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
                    .background(Color("PinkColor"), in: RoundedRectangle(cornerRadius: 10))
                }
                .onDelete(perform: { indexSet in
                    myPageVM.deleteRow(indexSet: indexSet)
                })
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .background(Color("CreamColor"), in: RoundedRectangle(cornerRadius: 10))
        }
        .listRowBackground(Color.clear)
        .listStyle(.plain)
        .alert(isPresented: $myPageVM.showBirthdayAlert) {
            Alert(title: Text("알림"), message: Text("생일은 삭제할 수 없습니다."), dismissButton: .default(Text("확인")))
        }
    }
}

#Preview {
    MyPageView()
}
