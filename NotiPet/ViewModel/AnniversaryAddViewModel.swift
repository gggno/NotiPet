import SwiftUI
import Combine
import RealmSwift

class AnniversaryAddViewModel: ObservableObject {
    
    var subscriptions = Set<AnyCancellable>()
    
    @Published var anniContent: String = ""
    @Published var anniContentMessage: String = ""
    @Published var anniDate: String = ""
    
    @Published var isValidation: Bool = false
    
    @Published var showBirthdayAlert = false
    
    var validAnniContentPublisher: AnyPublisher<Bool, Never> {
        $anniContent
            .map{$0.count >= 1}
            .eraseToAnyPublisher()
    }
    
    let petInfo = PetInfo()
    let realm = try! Realm()
    
    init() {
        print("AnniversaryViewModel - init() called")
        
        $anniDate
            .print("anniDate")
            .sink(receiveValue: { _ in
            }).store(in: &subscriptions)
        
        validAnniContentPublisher
            .receive(on: RunLoop.main)
            .map{$0 ? "" : "한 글자 이상 입력해주세요"}
            .assign(to: \.anniContentMessage, on: self)
            .store(in: &subscriptions)
        
        validAnniContentPublisher
            .receive(on: RunLoop.main)
            .map{$0 ? true : false}
            .assign(to: \.isValidation, on: self)
            .store(in: &subscriptions)
        
    }
    
    // 기념일 데이터 추가 후 전달
    func anniInfoSave() {
        print("AnniversaryViewModel - anniInfoSave()")
        
        if anniContent == "생일" {
            showBirthdayAlert.toggle()
            return
        }
        
        if let allData = realm.objects(PetInfo.self).first {
            print("로컬 DB에 기념일 데이터 추가")
            try! realm.write {
                if anniDate.dayConvertDate() == "0" {   // 기념일이 오늘일 때
                    allData.anniversaryDatas.append(AnniversaryData(identifier: UUID().uuidString, dDay: "D-Day", content: anniContent, dueDate: anniDate))
                } else {                                // 기념일이 아직 오지 않을 때
                    let addData = AnniversaryData(
                        identifier: UUID().uuidString,
                        dDay: "D\(anniDate.dayConvertDate())", 
                        content: anniContent, dueDate: anniDate
                    )
                    allData.anniversaryDatas.append(addData)
                    // 로컬 푸시 알림 등록
                    NotificationHandler.shered.anniversaryNotification(identifier: addData.identifier, dateString: addData.dueDate, title: "기념일 알림", body: addData.content)
                }
                
            }
            
            NotificationCenter.default.post(name: NSNotification.Name("anniDatas"), object: nil, userInfo: ["anniversaryDatas": Array(allData.anniversaryDatas)])
        }
    }
    
}
