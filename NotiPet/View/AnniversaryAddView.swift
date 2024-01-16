import SwiftUI

struct AnniversaryAddView: View {
    @Binding var isAnniViewPresented: Bool
    @StateObject var anniVM = AnniversaryAddViewModel()
    
    var body: some View {
        NavigationView {
            List {
                VStack {
                    Section {
                        InputTextFieldView(theme: "내용", content: $anniVM.anniContent, message: $anniVM.anniContentMessage, lineLimit: 2)
                    }
                    
                    Section {
                        AnniversaryAddDatePicker(anniDate: $anniVM.anniDate)
                            .frame(maxWidth: .infinity)
                    }
                }
                .navigationTitle("기념일 추가")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            isAnniViewPresented.toggle()
                        }, label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                        })
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            anniVM.anniInfoSave()
                            if !anniVM.showBirthdayAlert {
                                isAnniViewPresented.toggle()
                            }
                        }, label: {
                            Text("완료")
                        })
                        .disabled(!anniVM.isValidation)
                        .alert(isPresented: $anniVM.showBirthdayAlert) {
                            Alert(title: Text("알림"), message: Text("생일은 추가할 수 없습니다."), dismissButton: .default(Text("확인")))
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .onAppear(perform : UIApplication.shared.hideKeyboard)
        }
    }
}

//#Preview {
//    SpecialAnniversaryView(dDay: <#Binding<Int>#>, content: <#Binding<String>#>)
//}
