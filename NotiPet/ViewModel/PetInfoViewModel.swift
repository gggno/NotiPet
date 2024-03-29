import SwiftUI
import Photos
import Combine
import RealmSwift

class PetInfoViewModel: ObservableObject {
    
    var subscriptions = Set<AnyCancellable>()
    
    @Published var petProfileUIImage: UIImage?
    @Published var petName: String = ""
    @Published var species: String = ""
    @Published var birthDate: String = Date().convertDate()
    @Published var weight: String = ""
    @Published var sex: String = ""
    
    @Published var anniversaryDatas: [AnniversaryData] = []
    
    @Published var petNameMessage: String = ""
    @Published var speciesMessage: String = ""
    @Published var weightMessage: String = ""
    @Published var sexMessage: String = ""
    @Published var isValidation: Bool = false
    
    @Published var isImagePickerPresented: Bool = false
    @Published var isImageChoicePresented: Bool = false
    
    // petName 한 글자 이상 입력했는지 판단 유무
    var validPetNamePublisher: AnyPublisher<Bool, Never> {
        $petName
            .map{$0.count >= 1}
            .eraseToAnyPublisher()
    }
    
    // species 한 글자 이상 입력했는지 판단 유무
    var validSpeciesPublisher: AnyPublisher<Bool, Never> {
        $species
            .map{$0.count >= 1}
            .eraseToAnyPublisher()
    }
    
    // weight 실수형으로 입력했는지 판단 유무
    var validWeightPublisher: AnyPublisher<Bool, Never> {
        $weight
            .map{(Double($0) != nil) ? true : false}
            .eraseToAnyPublisher()
    }
    
    // sex 선택했는지 판단 유무
    var validSexPublisher: AnyPublisher<Bool, Never> {
        $sex
            .map{$0 == "" ? false : true}
            .eraseToAnyPublisher()
    }
    
    // petName, species, weight, sex 모두 조건을 만족했는지 판단 유무(만족했다면 "입력하기" 버튼 활성화)
    var validConfirmPublisher: AnyPublisher<Bool, Never> {
        Publishers
            .CombineLatest4(validPetNamePublisher, validSpeciesPublisher, validWeightPublisher, validSexPublisher)
            .map{$0 && $1 && $2 && $3}
            .eraseToAnyPublisher()
    }
    
    let petInfo = PetInfo()
    let realm = try! Realm()
    
    init() {
        print("PetInfoViewModel - init() called")
        // 로컬 디비 데이터 확인
        dataConfirm()
        
        validPetNamePublisher
            .receive(on: RunLoop.main)
            .map{$0 ? "" : "한 글자 이상 입력해주세요"}
            .assign(to: \.petNameMessage, on: self)
            .store(in: &subscriptions)
        
        validSpeciesPublisher
            .receive(on: RunLoop.main)
            .map{$0 ? "" : "한 글자 이상 입력해주세요"}
            .assign(to: \.speciesMessage, on: self)
            .store(in: &subscriptions)
        
        validWeightPublisher
            .receive(on: RunLoop.main)
            .map{$0 ? "" : "몸무게를 정확히 입력해주세요"}
            .assign(to: \.weightMessage, on: self)
            .store(in: &subscriptions)
        
        validSexPublisher
            .receive(on: RunLoop.main)
            .map{$0 ? "" : "성별을 선택해주세요"}
            .assign(to: \.sexMessage, on: self)
            .store(in: &subscriptions)
        
        validConfirmPublisher
            .receive(on: RunLoop.main)
            .map{$0 ? true : false}
            .assign(to: \.isValidation, on: self)
            .store(in: &subscriptions)
        
        $weight
            .removeDuplicates(by: { old, new in
                old == new
            })
            .map{$0.prefix(1) == "." ? "0"+$0 : $0}
            .map{$0.suffix(1) == "." ? $0+"0" : $0}
            .assign(to: \.weight, on: self)
            .store(in: &subscriptions)
    }
    
    // 정보가 있는지 확인. 있으면 화면에 출력하기 위한 용도
    func dataConfirm() {
        print("PetInfoViewModel - dataConfirm() called")
        
        if let data = realm.objects(PetInfo.self).first {
            print("펫정보가 로컬디비에 정보가 있다.")
            if let imageData = data.petProfileImageData {
                petProfileUIImage = UIImage(data: imageData)!
            }
            petName = data.petName
            species = data.species
            birthDate = data.birthDate
            weight = data.weight
            sex = data.sex
            
            anniversaryDatas = Array(data.anniversaryDatas)
        }
    }
    
    // 펫 정보를 로컬DB에 저장, 갱신
    func infoSave() {
        print("PetInfoViewModel - infoSave() called")
        
        if let data = realm.objects(PetInfo.self).first {   // 갱신
            print("펫정보 데이터 로컬 DB 갱신")
            try! realm.write {
                if data.birthDate != birthDate {    // 생일이 변경되었으면
                    let filterDatas = data.anniversaryDatas
                    let filterIndex = filterDatas.firstIndex(where: {$0.content == "생일"}) ?? 0
                    
                    filterDatas[filterIndex].dDay = PetInfoViewModel.calculateBirthdayDday(birthdate: birthDate)
                    filterDatas[filterIndex].dueDate = PetInfoViewModel.calculateBirthdayYear(birthdate: birthDate)
                    
                    data.anniversaryDatas = filterDatas
                    
                    // 새로 등록된 생일 로컬 푸시 알림 등록
                    NotificationHandler.shared.anniversaryNotification(
                        identifier: filterDatas[filterIndex].identifier,
                        dateString: filterDatas[filterIndex].dueDate,
                        title: "기념일 알림",
                        body: filterDatas[filterIndex].content
                    )
                }
                
                data.petProfileImageData = petProfileUIImage?.jpegData(compressionQuality: 1)
                data.petName = petName
                data.species = species
                data.birthDate = birthDate
                data.weight = weight
                data.sex = sex
            }
        } else {                                            // 저장
            print("펫정보 로컬 DB 최초 저장")
            try! realm.write {
                petInfo.petProfileImageData = petProfileUIImage?.jpegData(compressionQuality: 1)
                petInfo.petName = petName
                petInfo.species = species
                petInfo.birthDate = birthDate
                petInfo.weight = weight
                petInfo.sex = sex
                
                let birthdayData = AnniversaryData(identifier: UUID().uuidString, dDay: PetInfoViewModel.calculateBirthdayDday(birthdate: birthDate), content: "생일", dueDate: PetInfoViewModel.calculateBirthdayYear(birthdate: birthDate))
                
                petInfo.anniversaryDatas.append(birthdayData)
                anniversaryDatas.append(birthdayData)
                // 로컬 푸시 알림 등록
                NotificationHandler.shared.anniversaryNotification(
                    identifier: birthdayData.identifier,
                    dateString: PetInfoViewModel.calculateBirthdayYear(birthdate: birthDate),
                    title: "기념일 알림", body: birthdayData.content
                )
                
                // List를 배열로 변환 후 정렬
                let sortedArray = Array(petInfo.anniversaryDatas).sorted {
                    if let number1 = Int($0.dDay.components(separatedBy: "-").last ?? ""),
                       let number2 = Int($1.dDay.components(separatedBy: "-").last ?? "") {
                        if number1 != number2 {
                            return number1 < number2
                        }
                    } else {
                        return $0.dDay > $1.dDay
                    }
                    
                    return $0.content < $1.content
                }
                
                // 정렬된 배열을 다시 List로 변환
                petInfo.anniversaryDatas.removeAll()
                petInfo.anniversaryDatas.append(objectsIn: sortedArray)
                
                realm.add(petInfo)
            }
        }
    }
    
    // MyPageViewModel - recievedDatas()로 데이터 전달
    func sendData() {
        print("PetInfoViewModel - sendData() called")
        let infoDatas: [String: Any] = [
            "petProfileUIImage": petProfileUIImage,
            "petName": petName,
            "species": species,
            "birthDate": birthDate,
            "weight": weight,
            "sex": sex,
            
            "anniversaryDatas": anniversaryDatas
        ]
        
        // MyPageViewModel - recievedDatas로 데이터 전달
        NotificationCenter.default.post(name: NSNotification.Name("PetInfosData"), object: nil, userInfo: infoDatas)
    }
    
    // 생일 디데이 계산
    static func calculateBirthdayDday(birthdate: String) -> String {
        print("PetInfoViewModel - calculateBirthdayDday() called")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        
        let currentStringDate = Date().convertDate()
        
        let currentArr = currentStringDate.split(separator: " ").map{String($0)}
        let birthArr = birthdate.split(separator: " ").map{String($0)}
        
        let thisYearBirthDate = dateFormatter.date(from: [currentArr[0], birthArr[1], birthArr[2]].joined(separator: " "))!
        let currentDate = dateFormatter.date(from: currentStringDate)!
        print("currentDate: \(currentDate), thisYearBirthDate: \(thisYearBirthDate)")
        if currentDate > thisYearBirthDate {    // 올해 생일이 지난 경우
            print("올해 생일 지남")
            let calendar = Calendar.current
            let nextBirth = calendar.date(byAdding: .year, value: 1, to: thisYearBirthDate)!
            let components = calendar.dateComponents([.day], from: currentDate, to: nextBirth)
            let dDay = components.day!
            return "D\(dDay * -1)"
            
        } else if currentDate < thisYearBirthDate { // 올해 생일이 안 지난 경우
            print("올해 생일 안 지남")
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: currentDate, to: thisYearBirthDate)
            let dDay = components.day!
            return "D\(dDay * -1)"
            
        } else { // 오늘이 생일인 경우
            print("오늘이 생일")
            return "D-Day"
        }
    }
    
    // 매년 생일 날짜 계산
    static func calculateBirthdayYear(birthdate: String) -> String {
        print("PetInfoViewModel - calculateBirthdayYear() called")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        
        let currentStringDate = Date().convertDate()
        
        let currentArr = currentStringDate.split(separator: " ").map{String($0)}
        let birthArr = birthdate.split(separator: " ").map{String($0)}
        
        let thisYearBirthDate = dateFormatter.date(from: [currentArr[0], birthArr[1], birthArr[2]].joined(separator: " "))!
        let currentDate = dateFormatter.date(from: currentStringDate)!
        
        if currentDate > thisYearBirthDate {    // 올해 생일이 지난 경우
            print("올해 생일 지남")
            let calendar = Calendar.current
            let nextBirth = calendar.date(byAdding: .year, value: 1, to: thisYearBirthDate)!
            
            return nextBirth.convertDate()
            
        } else if currentDate < thisYearBirthDate { // 올해 생일이 안 지난 경우
            print("올해 생일 안 지남")
            return thisYearBirthDate.convertDate()
            
        } else { // 오늘이 생일인 경우
            print("오늘이 생일")
            return currentDate.convertDate()
        }
    }
    
    // 사진 권한
    func checkAndShowImagePicker() {
        print("PetInfoViewModel - checkAndShowImagePicker() called")
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            print("사진 권한 허용")
            // 권한이 허용된 경우
            isImagePickerPresented.toggle()
        case .restricted:
            // 사용자가 권한 거부 또는 제한
            print("사진권한 제한")
            // 권한을 요청하거나, 사용자에게 설정 앱으로 이동하도록 안내할 수 있습니다.
        case .denied:
            print("사진 권한 거부")
        case .notDetermined:
            print("아직 사진 권한을 결정하지 않음")
            // 사용자가 아직 권한을 결정하지 않음
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized {
                    DispatchQueue.main.async {
                        print("사진 권한이 허용됨")
                        self.isImagePickerPresented.toggle()
                    }
                }
            }
        @unknown default:
            fatalError("Unhandled case")
        }
    }
    
}
