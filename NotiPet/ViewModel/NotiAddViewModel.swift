import Foundation
import Combine
import RealmSwift

class NotiAddViewModel: ObservableObject {
    
    var subscriptions = Set<AnyCancellable>()
    
    @Published var notiContent: String = ""
    @Published var notiContentMessage: String = ""
    @Published var notiDate: String = ""
    
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
    
    
}
