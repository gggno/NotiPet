import SwiftUI
import Combine
import RealmSwift
import Photos

class NotiAddViewModel: ObservableObject {
    
    var subscriptions = Set<AnyCancellable>()
    
    @Published var modifyIdentifer: [String] = []
    
    @Published var notiContent: String = ""
    @Published var notiContentMessage: String = ""
    @Published var notiMemo: String = ""
    @Published var notiUIImage: UIImage?
    @Published var notiDate: Date = Date()
    
    @Published var notiRepeatType: RepeatType = RepeatType.none
    
    @Published var selectedDays: Set<Days> = []
    @Published var daysString: String = ""
    @Published var daysState: Bool = false
    
    @Published var isImageChoicePresented: Bool = false
    @Published var isImagePickerPresented: Bool = false
    
    @Published var isValidation: Bool = false
    
    var repeatDays: [Int] = []
    
    var validnotiContentPublisher: AnyPublisher<Bool, Never> {
        $notiContent
            .map{$0.count >= 1}
            .eraseToAnyPublisher()
    }
    
    // 매주 반복일 때 반복되는 요일 선택
    var validEveryweekPublisher: AnyPublisher<Bool, Never> {
        $notiRepeatType.combineLatest($selectedDays)
            .map { repeatType, selectedDays in
                if repeatType == RepeatType.everyweak {
                    return !selectedDays.isEmpty
                } else {
                    return true
                }
            }
            .eraseToAnyPublisher()
    }
    
    
    var validConfirmPublisher: AnyPublisher<Bool, Never> {
        Publishers
            .CombineLatest(validnotiContentPublisher, validEveryweekPublisher)
            .map{$0 && $1}
            .eraseToAnyPublisher()
    }
    
    let petInfo = PetInfo()
    let realm = try! Realm()
    
    init() {
        print("NotiAddViewModel - init() called")
        
        validnotiContentPublisher
            .receive(on: RunLoop.main)
            .map{$0 ? "" : "한 글자 이상 입력해주세요"}
            .assign(to: \.notiContentMessage, on: self)
            .store(in: &subscriptions)
        
        validConfirmPublisher
            .receive(on: RunLoop.main)
            .map{$0 ? true : false}
            .assign(to: \.isValidation, on: self)
            .store(in: &subscriptions)
        
        $selectedDays
            .sink { selectedDays in
                let sortedDays = selectedDays.sorted(by: { day1, day2 in
                    let order: [Days] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
                    return order.firstIndex(of: day1)! < order.firstIndex(of: day2)!
                })
                
                switch sortedDays {
                case [Days.sunday, Days.monday, Days.tuesday, Days.wednesday, Days.thursday, Days.friday, Days.saturday]:
                    self.daysString = "매일"
                case [Days.sunday, Days.saturday]:
                    self.daysString = "주말마다"
                case [Days.monday, Days.tuesday, Days.wednesday, Days.thursday, Days.friday]:
                    self.daysString = "평일마다"
                default:
                    let filterStr = sortedDays.map{$0.displayName}.joined(separator: ", ")
                    self.daysString = "\(filterStr)"
                }
                
                self.repeatDays = sortedDays.map{$0.displayNum}
                
                print(self.daysString)
            }
            .store(in: &subscriptions)
        
        $notiRepeatType
            .print("$notiRepeatType:")
            .sink { type in
                switch type {
                case .everyweak:
                    self.daysState = true
                default:
                    self.daysState = false
                    self.selectedDays.removeAll()
                    self.daysString = type.displayName
                }
            }
            .store(in: &subscriptions)
    }
    
    // 알림 정보 저장
    func sendNotiData() {
        print("NotiAddViewModel - sendNotiData() called")
        
        if let allData = realm.objects(PetInfo.self).first {
            
            print("로컬 DB에 알림 데이터 추가")
            var addData = NotiData()
            
            switch notiRepeatType {
            case .everyweak:    // 매주
                addData.content = notiContent
                addData.memo = notiMemo
                addData.notiDate = notiDate
                addData.repeatTypeDisplayName = notiRepeatType.displayName
                addData.daysString = daysString
                addData.notiUIImageData = notiUIImage?.jpegData(compressionQuality: 1)
                
                for day in repeatDays {
                    let id = UUID().uuidString
                    addData.identifier.append(id)
                    addData.weekDays.append(day)
                    
                    NotificationHandler.shered.notiNotification(
                        identifier: id,
                        notiContent: addData.content,
                        notiDate: addData.notiDate,
                        day: day,
                        repeatType: notiRepeatType)
                }
                
            case .everythreemonths: // 3개월마다
                var month: [Int] = [Calendar.current.component(.month, from: notiDate)]
                for _ in 0..<3 {
                    if ((month.last ?? 1) + 3) > 12 {
                        month.append(((month.last ?? 1) + 3) % 12)
                    } else {
                        month.append(((month.last ?? 1) + 3))
                    }
                }
                
                addData.content = notiContent
                addData.memo = notiMemo
                addData.notiDate = notiDate
                addData.repeatTypeDisplayName = notiRepeatType.displayName
                addData.daysString = daysString
                addData.notiUIImageData = notiUIImage?.jpegData(compressionQuality: 1)
                
                for m in month {
                    let id = UUID().uuidString
                    addData.identifier.append(id)
                    
                    NotificationHandler.shered.notiNotification(
                        identifier: id,
                        notiContent: addData.content,
                        notiDate: addData.notiDate,
                        month: m,
                        repeatType: notiRepeatType)
                }
                
            case .everysixmonths:   // 6개월마다
                var month: [Int] = [Calendar.current.component(.month, from: notiDate)]
                if ((month.last ?? 1) + 6) > 12 {
                    month.append(((month.last ?? 1) + 6) % 12)
                } else {
                    month.append(((month.last ?? 1) + 6))
                }
                
                addData.content = notiContent
                addData.memo = notiMemo
                addData.notiDate = notiDate
                addData.repeatTypeDisplayName = notiRepeatType.displayName
                addData.daysString = daysString
                addData.notiUIImageData = notiUIImage?.jpegData(compressionQuality: 1)
                
                for m in month {
                    let id = UUID().uuidString
                    addData.identifier.append(id)
                    
                    NotificationHandler.shered.notiNotification(
                        identifier: id,
                        notiContent: addData.content,
                        notiDate: addData.notiDate,
                        month: m,
                        repeatType: notiRepeatType)
                }
                
            default:
                addData.identifier.append(UUID().uuidString)
                addData.content = notiContent
                addData.memo = notiMemo
                addData.notiDate = notiDate
                addData.repeatTypeDisplayName = notiRepeatType.displayName
                addData.daysString = daysString
                addData.notiUIImageData = notiUIImage?.jpegData(compressionQuality: 1)
                
                NotificationHandler.shered.notiNotification(
                    identifier: addData.identifier.first ?? "",
                    notiContent: addData.content,
                    notiDate: addData.notiDate,
                    repeatType: notiRepeatType)
            }
            
            try! realm.write {
                allData.notiDatas.append(addData)
            }
            
            // 추가된 알림 정보를 알림 리스트로 전달
            NotificationCenter.default.post(name: NSNotification.Name("notiData"), object: nil, userInfo: ["notiDatas":addData])
        }
    }
    
    // 알림 정보 수정
    func modifyNotiData() {
        print("NotiAddViewModel - modifyNotiData() called")
        
        if let allData = realm.objects(PetInfo.self).first,
           let modifyIndex = allData.notiDatas.firstIndex(where: {$0.identifier.first == modifyIdentifer.first}) {
            
            // 기존에 등록된 알림 삭제
            NotificationHandler.shered.removeRegisteredNotification(identifiers: Array(allData.notiDatas[modifyIndex].identifier))
            
            var addData = NotiData()
            
            // 반복 타입에 따라 데이터 넣기
            switch notiRepeatType {
            case .everyweak:    // 매주
                addData.content = notiContent
                addData.memo = notiMemo
                addData.notiDate = notiDate
                addData.repeatTypeDisplayName = notiRepeatType.displayName
                addData.daysString = daysString
                addData.notiUIImageData = notiUIImage?.jpegData(compressionQuality: 1)
                
                for day in repeatDays {
                    let id = UUID().uuidString
                    addData.identifier.append(id)
                    addData.weekDays.append(day)
                    
                    NotificationHandler.shered.notiNotification(
                        identifier: id,
                        notiContent: addData.content,
                        notiDate: addData.notiDate,
                        day: day,
                        repeatType: notiRepeatType)
                }
                
            case .everythreemonths: // 3개월마다
                var month: [Int] = [Calendar.current.component(.month, from: notiDate)]
                for _ in 0..<3 {
                    if ((month.last ?? 1) + 3) > 12 {
                        month.append(((month.last ?? 1) + 3) % 12)
                    } else {
                        month.append(((month.last ?? 1) + 3))
                    }
                }
                
                addData.content = notiContent
                addData.memo = notiMemo
                addData.notiDate = notiDate
                addData.repeatTypeDisplayName = notiRepeatType.displayName
                addData.daysString = daysString
                addData.notiUIImageData = notiUIImage?.jpegData(compressionQuality: 1)
                
                for m in month {
                    let id = UUID().uuidString
                    addData.identifier.append(id)
                    
                    NotificationHandler.shered.notiNotification(
                        identifier: id,
                        notiContent: addData.content,
                        notiDate: addData.notiDate,
                        month: m,
                        repeatType: notiRepeatType)
                }
                
            case .everysixmonths:   // 6개월마다
                var month: [Int] = [Calendar.current.component(.month, from: notiDate)]
                if ((month.last ?? 1) + 6) > 12 {
                    month.append(((month.last ?? 1) + 6) % 12)
                } else {
                    month.append(((month.last ?? 1) + 6))
                }
                
                addData.content = notiContent
                addData.memo = notiMemo
                addData.notiDate = notiDate
                addData.repeatTypeDisplayName = notiRepeatType.displayName
                addData.daysString = daysString
                addData.notiUIImageData = notiUIImage?.jpegData(compressionQuality: 1)
                
                for m in month {
                    let id = UUID().uuidString
                    addData.identifier.append(id)
                    
                    NotificationHandler.shered.notiNotification(
                        identifier: id,
                        notiContent: addData.content,
                        notiDate: addData.notiDate,
                        month: m,
                        repeatType: notiRepeatType)
                }
                
            default:
                addData.identifier.append(UUID().uuidString)
                addData.content = notiContent
                addData.memo = notiMemo
                addData.notiDate = notiDate
                addData.repeatTypeDisplayName = notiRepeatType.displayName
                addData.daysString = daysString
                addData.notiUIImageData = notiUIImage?.jpegData(compressionQuality: 1)
                
                NotificationHandler.shered.notiNotification(
                    identifier: addData.identifier.first ?? "",
                    notiContent: addData.content,
                    notiDate: addData.notiDate,
                    repeatType: notiRepeatType)
            }
            
            // 수정된 알림 데이터 전달
            NotificationCenter.default.post(name: NSNotification.Name("modifyDataIdentifer"),
                                            object: nil,
                                            userInfo: [
                                                "identiferFirst": allData.notiDatas[modifyIndex].identifier.first,
                                                "modifyData": addData])
            
            // 로컬 DB 알림 데이터 수정
            try! realm.write {
                print("allData.notiDatas before: \(allData.notiDatas)")
                allData.notiDatas[modifyIndex] = addData
                print("allData.notiDatas after: \(allData.notiDatas)")
            }
        }
    }
    
    // 수정할때 매주 요일 가져오기
    func getDays(weekDays: [Int]) -> Set<Days> {
        print("NotiAddViewModel - getDays() called")
        var setDays: Set<Days> = []
        
        for day in weekDays {
            if let displayNum = Days.allCases.first(where: {$0.displayNum == day}) {
                setDays.insert(displayNum)
            }
        }

        return setDays
    }
    
    // 수정할때 타입 가져오기
    func getRepeatType(displayName: String) -> RepeatType {
        print("NotiAddViewModel - getRepeatType() called")
        guard let selectedType = RepeatType.allCases.first(where: { $0.displayName == displayName }) else { return RepeatType.none }
        return selectedType
    }
    
    // 사진 권한
    func checkAndShowImagePicker() {
        print("NotiAddViewModel - checkAndShowImagePicker() called")
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
