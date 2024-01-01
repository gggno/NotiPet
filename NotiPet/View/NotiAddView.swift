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
                    .padding(.bottom, 8)
                    if notiVM.daysState {
                        DaysButtonView(selectedDays: $notiVM.selectedDays)
                        .listRowSeparator(.hidden)
                    }
                }
                
                Section {
                    ZStack {
                        Text("이미지 추가")
                            .foregroundStyle(.blue)
                            .zIndex(0)
                        
                        if let image = notiVM.notiUIImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .zIndex(1)
                        }
                    }
                    .frame(width: 600, height: 300)
                    .onTapGesture {
                        notiVM.isImageChoicePresented.toggle()
                    }
                    .confirmationDialog(
                        "알림 이미지 설정",
                        isPresented: $notiVM.isImageChoicePresented,
                        actions: {
                            Button(action: {
                                notiVM.checkAndShowImagePicker()
                            }, label: {
                                Text("사진 선택")
                            })
                            
                            Button(action: {
                                notiVM.notiUIImage = nil
                            }, label: {
                                Text("사진 삭제")
                            })
                        })
                    .sheet(isPresented: $notiVM.isImagePickerPresented) {
                        ImagePicker(selectedUIImage: $notiVM.notiUIImage)
                    }
                }
                
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
                        notiVM.sendNotiData()
                        isNotiAddPresented.toggle()
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
