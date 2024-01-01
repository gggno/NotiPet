import SwiftUI
import Combine
import RealmSwift
import Photos

class NotiAddViewModel: ObservableObject {
    
    var subscriptions = Set<AnyCancellable>()
    
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
        NotificationHandler.shered.checkRegisteredNotification()
        
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
                
                print("선택한 요일: \(sortedDays.map { $0.displayName })")
                
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
            .sink { type in
                switch type {
                case .everyweak:
                    self.daysState = true
                default:
                    self.daysState = false
                    self.selectedDays.removeAll()
                    self.daysString = ""
                }
            }
            .store(in: &subscriptions)
        
    }
    
    // 알림 정보 저장
    func sendNotiData() {
        print("NotiAddViewModel - sendNotiData() called")
        
        if let allData = realm.objects(PetInfo.self).first {
            print("로컬 DB에 알림 데이터 추가")
            
            switch notiRepeatType {
            case .everyweak:    // 매주
                let addData = NotiData()
                addData.content = notiContent
                addData.memo = notiMemo
                addData.notiDate = notiDate
                addData.daysString = daysString
                
                for day in repeatDays {
                    let id = UUID().uuidString
                    addData.identifier.append(id)
                    
                    NotificationHandler.shered.notiNotification(
                        identifier: id,
                        notiContent: addData.content,
                        notiDate: addData.notiDate,
                        day: day,
                        repeatType: notiRepeatType)
                }
                
                try! realm.write {
                    allData.notiDatas.append(addData)
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
                
                let addData = NotiData()
                addData.content = notiContent
                addData.memo = notiMemo
                addData.notiDate = notiDate
                addData.daysString = daysString
                
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
                
                try! realm.write {
                    allData.notiDatas.append(addData)
                }
            case .everysixmonths:   // 6개월마다
                var month: [Int] = [Calendar.current.component(.month, from: notiDate)]
                if ((month.last ?? 1) + 6) > 12 {
                    month.append(((month.last ?? 1) + 6) % 12)
                } else {
                    month.append(((month.last ?? 1) + 6))
                }
                
                let addData = NotiData()
                addData.content = notiContent
                addData.memo = notiMemo
                addData.notiDate = notiDate
                addData.daysString = daysString
                
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
                
                try! realm.write {
                    allData.notiDatas.append(addData)
                }
            default:
                let addData = NotiData()
                addData.identifier.append(UUID().uuidString)
                addData.content = notiContent
                addData.memo = notiMemo
                addData.notiDate = notiDate
                addData.daysString = daysString
                
                try! realm.write {
                    allData.notiDatas.append(addData)
                }
                
                NotificationHandler.shered.notiNotification(
                    identifier: addData.identifier.first ?? "",
                    notiContent: addData.content,
                    notiDate: addData.notiDate,
                    repeatType: notiRepeatType)
            }
        }
        
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
