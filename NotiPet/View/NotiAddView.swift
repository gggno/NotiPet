import SwiftUI

struct NotiAddView: View {
    @Binding var isNotiAddPresented: Bool
    @StateObject var notiaddVM: NotiAddViewModel = NotiAddViewModel()
    
    @Binding var modifyData: NotiData?
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    InputTextFieldView(theme: "내용", content: $notiaddVM.notiContent, message: $notiaddVM.notiContentMessage, lineLimit: 2)
                    VStack(alignment: .leading) {
                        Text("메모")
                        TextField(
                            "",
                            text: $notiaddVM.notiMemo,
                            axis: .vertical
                        )
                        .lineLimit(3)
                        .textInputAutocapitalization(.never)
                        .textFieldStyle(.roundedBorder)
                    }
                }
                
                Section {
                    NotiAddDatePicker(notiDate: $notiaddVM.notiDate)
                    NavigationLink(destination: RepeatListView(repeatType: $notiaddVM.notiRepeatType)) {
                        HStack {
                            Text("반복")
                            Spacer()
                            Text(notiaddVM.notiRepeatType.displayName)
                        }
                    }
                    .padding(.bottom, 8)
                    if notiaddVM.daysState {
                        DaysButtonView(selectedDays: $notiaddVM.selectedDays)
                        .listRowSeparator(.hidden)
                    }
                }
                
                Section {
                    ZStack {
                        Text("이미지 추가")
                            .foregroundStyle(.blue)
                            .zIndex(0)
                        
                        if let image = notiaddVM.notiUIImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .zIndex(1)
                        }
                    }
                    .frame(width: 600, height: 300)
                    .onTapGesture {
                        notiaddVM.isImageChoicePresented.toggle()
                    }
                    .confirmationDialog(
                        "알림 이미지 설정",
                        isPresented: $notiaddVM.isImageChoicePresented,
                        actions: {
                            Button(action: {
                                notiaddVM.checkAndShowImagePicker()
                            }, label: {
                                Text("사진 선택")
                            })
                            
                            Button(action: {
                                notiaddVM.notiUIImage = nil
                            }, label: {
                                Text("사진 삭제")
                            })
                        })
                    .sheet(isPresented: $notiaddVM.isImagePickerPresented) {
                        ImagePicker(selectedUIImage: $notiaddVM.notiUIImage)
                    }
                }
            }
            .navigationTitle(modifyData == nil ? "알림 추가" : "알림 수정")
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
                        if modifyData == nil {          // 알림 추가
                            notiaddVM.sendNotiData()
                        } else if modifyData != nil {   // 알림 수정
                            notiaddVM.modifyNotiData()
                        }
                        isNotiAddPresented.toggle()
                    }, label: {
                        Text("완료")
                    })
                    .disabled(!notiaddVM.isValidation)
                }
            }
            .listStyle(.insetGrouped)
            .onAppear(perform : UIApplication.shared.hideKeyboard)
            .onAppear { // 알림 수정할 때 들어오는 데이터
                if let modifyData = modifyData {
                    notiaddVM.modifyIdentifer = Array(modifyData.identifier)
                    notiaddVM.notiContent = modifyData.content
                    notiaddVM.notiMemo = modifyData.memo
                    notiaddVM.notiDate = modifyData.notiDate
                    notiaddVM.selectedDays = notiaddVM.getDays(weekDays: Array(modifyData.weekDays))
                    notiaddVM.daysString = modifyData.daysString
                    notiaddVM.notiRepeatType = notiaddVM.getRepeatType(displayName: modifyData.repeatTypeDisplayName)
                    if let imageData = modifyData.notiUIImageData {
                        notiaddVM.notiUIImage = UIImage(data: imageData)
                    }
                }
            }
        }
    }
}
