import SwiftUI

struct NotiAddView: View {
    @Binding var isNotiAddPresented: Bool
    @StateObject var notiVM: NotiAddViewModel = NotiAddViewModel()
    
    @State var selectedDate: Date = Date() // 임시
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    InputTextFieldView(theme: "내용", content: $notiVM.notiContent, message: $notiVM.notiContentMessage, lineLimit: 2)
                    VStack(alignment: .leading) {
                        Text("메모")
                        TextField(
                            "",
                            text: $notiVM.notiMemo,
                            axis: .vertical
                        )
                        .lineLimit(3)
                        .textInputAutocapitalization(.never)
                        .textFieldStyle(.roundedBorder)
                    }
                }
                
                Section {
                    DatePicker_Graphical2(notiDate: $notiVM.notiDate)
                    NavigationLink(destination: RepeatListView(repeatType: $notiVM.notiRepeatType)) {
                        HStack {
                            Text("반복")
                            Spacer()
                            Text(notiVM.notiRepeatType.displayName)
                        }
                    }
                }
                
//                Section {
//                    if notiVM.notiImage == UIImage(systemName: "photo")! {
//                        
//                    } else {
//                        Image(uiImage: notiVM.notiImage)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 600, height: 300)
//                            .onTapGesture {
//                                notiVM.isImageChoicePresented.toggle()
//                            }
//                            .confirmationDialog(
//                                "알림 이미지 설정",
//                                isPresented: $notiVM.isImageChoicePresented,
//                                actions: {
//                                    Button(action: {
//                                        notiVM.checkAndShowImagePicker()
//                                    }, label: {
//                                        Text("사진 선택")
//                                    })
//                                    
//                                    Button(action: {
//                                        notiVM.notiImage = UIImage(systemName: "photo")!
//                                    }, label: {
//                                        Text("사진 삭제")
//                                    })
//                                })
//                            .sheet(isPresented: $notiVM.isImagePickerPresented) {
//                                ImagePicker(selectedUIImage: $notiVM.notiImage)
//                            }
//                    }
//                }
                
            }
            .navigationTitle("알림 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        isNotiAddPresented.toggle()
                    }, label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.black)
                    })
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        
                    }, label: {
                        Text("완료")
                    })
                    .disabled(!notiVM.isValidation)
                }
            }
            .listStyle(.insetGrouped)
            .onAppear(perform : UIApplication.shared.hideKeyboard)
        }
    }
}

//#Preview {
//    NotiAddView()
//}
