import SwiftUI
import Combine
import RealmSwift

class AnniversaryViewModel: ObservableObject {
    
    var subscriptions = Set<AnyCancellable>()
    
    @Published var anniContent: String = ""
    @Published var anniContentMessage: String = ""
    @Published var anniDate: String = ""
    
    @Published var isValidation: Bool = false
    
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
        
        if let allData = realm.objects(PetInfo.self).first {
            print("로컬 DB에 기념일 데이터 추가")
            try! realm.write {
                if anniDate.dayConvertDate() == "0" {
                    allData.anniversaryDatas.append(AnniversaryData(dDay: "D-Day", content: anniContent, dueDate: anniDate))
                } else {
                    allData.anniversaryDatas.append(AnniversaryData(dDay: "D\(anniDate.dayConvertDate())", content: anniContent, dueDate: anniDate))
                }
                
            }
            
            NotificationCenter.default.post(name: NSNotification.Name("anniDatas"), object: nil, userInfo: ["anniversaryDatas": Array(allData.anniversaryDatas)])
        }
    }
    
}
