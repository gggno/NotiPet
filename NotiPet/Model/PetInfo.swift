import Foundation
import RealmSwift

class PetInfo: Object {
    @Persisted var petProfileImageData: Data?
    @Persisted var petName: String = ""
    @Persisted var species: String = ""
    @Persisted var birthDate: String = ""
    @Persisted var weight: String = ""
    @Persisted var sex: String = ""
    @Persisted var anniversaryDatas = List<AnniversaryData>()
    @Persisted var notiDatas = List<NotiData>()
}

// 기념일 데이터
class AnniversaryData: Object {
    @Persisted var identifier: String
    @Persisted var dDay: String
    @Persisted var content: String
    @Persisted var dueDate: String
    
    convenience init(identifier: String, dDay: String, content: String, dueDate: String) {
        self.init()
        self.identifier = identifier
        self.dDay = dDay
        self.content = content
        self.dueDate = dueDate
    }
}

// 할일 데이터
class NotiData: Object {
    @Persisted var identifier: List<String>
    @Persisted var content: String
    @Persisted var memo: String
    @Persisted var notiDate: Date
    @Persisted var daysString: String
    @Persisted var notiUIImageData: Data?
    
    convenience init(identifier: List<String>, content: String, memo: String, notiDate: Date, daysString: String, notiUIImageData: Data? = nil) {
        self.init()
        self.identifier = identifier
        self.content = content
        self.memo = memo
        self.notiDate = notiDate
        self.daysString = daysString
        self.notiUIImageData = notiUIImageData
    }
}
