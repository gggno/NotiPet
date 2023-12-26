import SwiftUI
import Combine
import RealmSwift
import Photos

enum RepeatType: CaseIterable {
    case none
    case everyday
    case weakday
    case weakend
    case everyweak
    case everymonth
    case everythreemonths
    case everysixmonths
    
    var displayName: String {
        switch self {
        case .none:
            return "안 함"
        case .everyday:
            return "매일"
        case .weakday:
            return "평일"
        case .weakend:
            return "주말"
        case .everyweak:
            return "매주"
        case .everymonth:
            return "매월"
        case .everythreemonths:
            return "3개월마다"
        case .everysixmonths:
            return "6개월마다"
        }
    } 
}

class NotiAddViewModel: ObservableObject {
    
    var subscriptions = Set<AnyCancellable>()
    
    @Published var notiContent: String = ""
    @Published var notiContentMessage: String = ""
    @Published var notiMemo: String = ""
    @Published var notiImage: UIImage = UIImage(systemName: "photo")!
    @Published var notiDate: Date = Date()
    
    @Published var notiRepeatType: RepeatType = RepeatType.none
    
    @Published var isImageChoicePresented: Bool = false
    @Published var isImagePickerPresented: Bool = false
    

    
    @Published var isValidation: Bool = false
    
    
    var validnotiContentPublisher: AnyPublisher<Bool, Never> {
        $notiContent
            .map{$0.count >= 1}
            .eraseToAnyPublisher()
    }
    
    let petInfo = PetInfo()
    let realm = try! Realm()
    
    init() {
        print("NotiAddViewModel - init() called")
        
        $notiContent
            .print("anniDate")
            .sink(receiveValue: { _ in
            }).store(in: &subscriptions)
        
        validnotiContentPublisher
            .receive(on: RunLoop.main)
            .map{$0 ? "" : "한 글자 이상 입력해주세요"}
            .assign(to: \.notiContentMessage, on: self)
            .store(in: &subscriptions)
        
        validnotiContentPublisher
            .receive(on: RunLoop.main)
            .map{$0 ? true : false}
            .assign(to: \.isValidation, on: self)
            .store(in: &subscriptions)
        
        
        
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
    
    
}
