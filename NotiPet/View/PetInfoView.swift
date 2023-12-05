import SwiftUI
import Photos

struct PetInfoView: View {
    @Binding var isPresented: Bool  // 등록하기 버튼 터치에 사용
    @State var isDatePickerPresented: Bool = false  // 생년월일 버튼에 사용
    @State var isImageChoicePresented: Bool = false // 프로필이미지 종류 선택 버튼에 사용
    @StateObject var petInfoVM = PetInfoViewModel()
    
    var body: some View {
        VStack {
            Text("우리 아이 정보")
            Spacer()
            Group {
                Button(action: {
                    isImageChoicePresented.toggle()
                }, label: {
                    Image(uiImage: petInfoVM.petProfileUIImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill )
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        .frame(width: 100, height: 100)
                })
                .confirmationDialog(
                    "프로필 이미지 설정",
                    isPresented: $isImageChoicePresented,
                    actions: {
                        Button(action: {
                            petInfoVM.checkAndShowImagePicker()
                        }, label: {
                            Text("사진 선택")
                        })
                        
                        Button(action: {
                            petInfoVM.petProfileUIImage = UIImage(systemName: "teddybear.fill")!
                        }, label: {
                            Text("기본 이미지로 설정")
                        })
                    })
                .sheet(isPresented: $petInfoVM.isImagePickerPresented) {
                    ImagePicker(selectedUIImage: $petInfoVM.petProfileUIImage)
                }
                
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
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("성별")
                        Text(petInfoVM.sexMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                    HStack {
                        Button(action: {
                            petInfoVM.sex = "남아"
                        }) {
                            Text("남아")
                                .frame(width: 130, height: 45)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                        }
                        .background(petInfoVM.sex == "남아" ? Color.yellow : Color.white)
                        .cornerRadius(10)
                        
                        Spacer()
                        Button(action: {
                            petInfoVM.sex = "여아"
                        }, label: {
                            Text("여아")
                                .frame(width: 130, height: 45)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.purple, lineWidth: 1)
                                )
                        })
                        .background(petInfoVM.sex == "여아" ? Color.yellow : Color.white)
                        .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity)
                }
                .background(Color.green)
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .padding(.bottom, 20)
            Spacer()
            Button(action: {
                isPresented.toggle()
                petInfoVM.infoSave()
                petInfoVM.sendData()
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
