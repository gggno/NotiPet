import SwiftUI
import Photos

struct PetInfoView: View {
    @Binding var isPresented: Bool  // 등록하기 버튼 터치에 사용
    @State var isDatePickerPresented: Bool = false  // 생년월일 버튼에 사용
    @StateObject var petInfoVM = PetInfoViewModel()
    
    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    Text("우리 아이 정보")
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    ZStack {
                        Image("PetBasicProfile")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            .frame(width: 100, height: 100)
                            .zIndex(0)
                        
                        if let image = petInfoVM.petProfileUIImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                .zIndex(1)
                        }
                    }
                    .frame(width: 100, height: 100)
                    .onTapGesture {
                        petInfoVM.isImageChoicePresented.toggle()
                    }
                    .confirmationDialog(
                        "프로필 이미지 설정",
                        isPresented: $petInfoVM.isImageChoicePresented,
                        actions: {
                            Button(action: {
                                petInfoVM.checkAndShowImagePicker()
                            }, label: {
                                Text("사진 선택")
                            })
                            
                            Button(action: {
                                petInfoVM.petProfileUIImage = nil
                            }, label: {
                                Text("기본 이미지로 설정")
                            })  
                        })
                    .sheet(isPresented: $petInfoVM.isImagePickerPresented) {
                        ImagePicker(selectedUIImage: $petInfoVM.petProfileUIImage)
                    }
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            Spacer()
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            
            Section {
                InputTextFieldView(theme: "이름", content: $petInfoVM.petName, message: $petInfoVM.petNameMessage, lineLimit: 1)
                InputTextFieldView(theme: "품종", content: $petInfoVM.species, message: $petInfoVM.speciesMessage, lineLimit: 1)
                InputTextFieldView(theme: "몸무게(kg)", content: $petInfoVM.weight, message: $petInfoVM.weightMessage, lineLimit: 1)
                VStack(alignment: .center, spacing: 10) {
                    Text("생년월일")
                        .font(.body)
                    HStack(alignment: .center) {
                        Button(action: {
                            isDatePickerPresented.toggle()
                        }, label: {
                            Text(petInfoVM.birthDate)
                                .foregroundStyle(.blue)
                        })
                        .sheet(isPresented: $isDatePickerPresented) {
                            DatePicker_WheelView(isDatePickerPresented: $isDatePickerPresented, birthDate: $petInfoVM.birthDate)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                VStack(alignment: .leading) {
                    HStack {
                        Text("성별")
                        Text(petInfoVM.sexMessage)
                            .font(.body)
                            .foregroundStyle(.red)
                    }
                    HStack {
                        Text("남아")
                            .frame(width: 130, height: 45)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .background(petInfoVM.sex == "남아" ? Color("CreamColor") : Color.white)
                            .cornerRadius(10)
                            .onTapGesture {
                                petInfoVM.sex = "남아"
                            }
                        
                        Spacer()
                        
                        Text("여아")
                            .frame(width: 130, height: 45)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .background(petInfoVM.sex == "여아" ? Color("CreamColor") : Color.white)
                            .cornerRadius(10)
                            .onTapGesture {
                                petInfoVM.sex = "여아"
                            }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented.toggle()
                        petInfoVM.infoSave()
                        petInfoVM.sendData()
                    }, label: {
                        Text("등록하기")
                            .foregroundStyle(.white)
                    })
                    .padding(.bottom, 70)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!petInfoVM.isValidation)
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        } 
        .listStyle(.plain)
        .onAppear(perform : UIApplication.shared.hideKeyboard)
    }
    
}
