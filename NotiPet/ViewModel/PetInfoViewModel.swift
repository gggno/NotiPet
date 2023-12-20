import SwiftUI
import Photos
import Combine
import RealmSwift

class PetInfoViewModel: ObservableObject {
    
    var subscriptions = Set<AnyCancellable>()
    
    @Published var petProfileUIImage: UIImage = UIImage(systemName: "pawprint.circle.fill")!
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
    
    var validPetNamePublisher: AnyPublisher<Bool, Never> {
        $petName
            .map{$0.count >= 1}
            .eraseToAnyPublisher()
    }
    
    var validSpeciesPublisher: AnyPublisher<Bool, Never> {
        $species
            .map{$0.count >= 1}
            .eraseToAnyPublisher()
    }
    
    var validWeightPublisher: AnyPublisher<Bool, Never> {
        $weight
            .map{(Double($0) != nil) ? true : false}
            .eraseToAnyPublisher()
    }
    
    var validSexPublisher: AnyPublisher<Bool, Never> {
        $sex
            .map{$0 == "" ? false : true}
            .eraseToAnyPublisher()
    }
    
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
        
        $petProfileUIImage
            .print("petProfileUIImage")
            .sink(receiveValue: { _ in
            }).store(in: &subscriptions)
        
        $petName
            .print("petName")
            .sink(receiveValue: { _ in
            }).store(in: &subscriptions)
        
        $species
            .print("species")
            .sink(receiveValue: { _ in
            }).store(in: &subscriptions)
        
        $birthDate
            .print("birthDate")
            .sink(receiveValue: { _ in
            }).store(in: &subscriptions)
        
        $weight
            .removeDuplicates(by: { old, new in
                old == new
            })
            .map{$0.prefix(1) == "." ? "0"+$0 : $0}
            .map{$0.suffix(1) == "." ? $0+"0" : $0}
            .print("weight")
            .assign(to: \.weight, on: self)
            .store(in: &subscriptions)
        
        $sex
            .print("sex")
            .sink(receiveValue: { _ in
            }).store(in: &subscriptions)
    }
    
    // 정보가 있는지 확인. 있으면 화면에 출력하기 위한 용도
    func dataConfirm() {
        print("PetInfoViewModel - dataConfirm() called")
        if let data = realm.objects(PetInfo.self).first {
            print("dataConfirm() - 로컬디비에 정보가 있다.")
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
            print("로컬 DB 갱신")
            try! realm.write {
                if data.birthDate != birthDate {    // 생일이 변경되었으면
                    let filterDatas = data.anniversaryDatas
                    let filterIndex = filterDatas.firstIndex(where: {$0.content == "생일"}) ?? 0
                    
                    filterDatas[filterIndex].dDay = calculateBirthdayDday(birthdate: birthDate)
                    filterDatas[filterIndex].dueDate = calculateBirthdayYear(birthdate: birthDate)
                    data.anniversaryDatas = filterDatas
                    
                    
                    
                }
                
                data.petProfileImageData = petProfileUIImage.jpegData(compressionQuality: 1)
                data.petName = petName
                data.species = species
                data.birthDate = birthDate
                data.weight = weight
                data.sex = sex
            }
        } else {                                            // 저장
            print("로컬 DB 최초 저장")
            try! realm.write {
                petInfo.petProfileImageData = petProfileUIImage.jpegData(compressionQuality: 1)
                petInfo.petName = petName
                petInfo.species = species
                petInfo.birthDate = birthDate
                petInfo.weight = weight
                petInfo.sex = sex
                
                petInfo.anniversaryDatas.append(AnniversaryData(dDay: calculateBirthdayDday(birthdate: birthDate), content: "생일", dueDate: calculateBirthdayYear(birthdate: birthDate)))
                
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
                print(sortedArray)
                
                // 정렬된 배열을 다시 List로 변환
                petInfo.anniversaryDatas.removeAll()
                petInfo.anniversaryDatas.append(objectsIn: sortedArray)
                
                realm.add(petInfo)
            }
        }
    }
    
    // MyPageViewModel - recievedDatas()로 데이터 전달
    func sendData() {
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
    
    // 사진 권한
    func checkAndShowImagePicker() {
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
    
    // 생일 디데이 계산
    func calculateBirthdayDday(birthdate: String) -> String {
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
    func calculateBirthdayYear(birthdate: String) -> String {
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
            let components = calendar.dateComponents([.year, .month ,.day], from: currentDate, to: nextBirth)
            let dYear = components.year!
            let dMonth = components.month!
            let dDay = components.day!
            
            return "\(dYear)년 \(dMonth)월 \(dDay)일"
            
        } else if currentDate < thisYearBirthDate { // 올해 생일이 안 지난 경우
            print("올해 생일 안 지남")
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month ,.day], from: currentDate, to: thisYearBirthDate)
            let dDay = components.day!
            
            return Date(timeIntervalSinceNow: TimeInterval(dDay*86400)).convertDate()
            
        } else { // 오늘이 생일인 경우
            print("오늘이 생일")
            return birthdate
        }
    }
    
}
