import SwiftUI

struct AnniversaryView: View {
    @Binding var isAnniViewPresented: Bool
    @StateObject var anniVM = AnniversaryViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text("내용")
                        Text(anniVM.anniContentMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                    TextField(
                        "",
                        text: $anniVM.anniContent
                    )
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .border(.black)
                }
                
                Spacer()
                    .frame(height: 30)
                
                DatePicker_Graphical(anniContent: $anniVM.anniContent, anniDate: $anniVM.anniDate)
                    .frame(maxWidth: .infinity)
                
                Spacer()
                
                Button(action: {
                    anniVM.anniInfoSave()
                    if !anniVM.showBirthdayAlert {
                        isAnniViewPresented.toggle()
                    }
                }, label: {
                    Text("추가하기")
                })
                .padding(.bottom, 70)
                .disabled(!anniVM.isValidation)
                .alert(isPresented: $anniVM.showBirthdayAlert) {
                    Alert(title: Text("알림"), message: Text("생일은 추가할 수 없습니다."), dismissButton: .default(Text("확인")))
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
            }
            .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
        }
        .onAppear(perform : UIApplication.shared.hideKeyboard)
    }
}

//#Preview {
//    SpecialAnniversaryView(dDay: <#Binding<Int>#>, content: <#Binding<String>#>)
//}
