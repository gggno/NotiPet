import SwiftUI

struct PetInfoView: View {
    @Binding var isPresented: Bool
    @State var isDatePickerPresented: Bool = false
    @StateObject var petInfoVM = PetInfoViewModel()
    
    var body: some View {
        VStack {
            Text("우리 아이 정보")
            Spacer()
            Group {
                VStack(alignment: .leading) {
                    HStack {
                        Text("이름")
                        Text(petInfoVM.petNameMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                    TextField(
                        "",
                        text: $petInfoVM.petName
                    )
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .border(.black)
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("품종")
                        Text(petInfoVM.speciesMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                    TextField(
                        "",
                        text: $petInfoVM.species
                    )
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .border(.black)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("생년월일")
                    HStack {
                        Button(action: {
                            isDatePickerPresented.toggle()
                        }, label: {
                            Text(petInfoVM.birthDate)
                            Spacer()
                        })
                        .border(.black)
                        .sheet(isPresented: $isDatePickerPresented) {
                            DatePicker_WheelView(isDatePickerPresented: $isDatePickerPresented, birthDate: $petInfoVM.birthDate)
                                .frame(height: UIScreen.main.bounds.height / 2) // 화면의 절반만 표시
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("몸무게")
                        Text(petInfoVM.weightMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                    HStack {
                        TextField(
                            "",
                            text: $petInfoVM.weight
                        )
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .keyboardType(.decimalPad)
                        .border(.black)
                        Text("kg")
                    }
                }
                
                VStack(alignment: .center) {
                    HStack {
                        Text("성별")
                        Spacer()
                    }
                    HStack {
                        Button(action: {
                            petInfoVM.sex = "남아"
                        }, label: {
                            Text("남아")
                        })
                        .buttonStyle(.borderedProminent)
                        Button(action: {
                            petInfoVM.sex = "여아"
                        }, label: {
                            Text("여아")
                        })
                        .buttonStyle(.borderedProminent)
                    }
                }
                .background(Color.red)
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .padding(.bottom, 20)
            Spacer()
            Button(action: {
                isPresented.toggle()
                petInfoVM.infoSave()
            }, label: {
                Text("등록하기")
            })
            .padding(.bottom, 70)
            .disabled(!petInfoVM.isValidation)
            
        }
        .onAppear(perform : UIApplication.shared.hideKeyboard)
        .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
    }
}
