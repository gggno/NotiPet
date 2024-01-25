import Foundation
import RealmSwift

class PetInfo: Object {
    // 펫정보 데이터
    @Persisted var petProfileImageData: Data?
    @Persisted var petName: String = ""
    @Persisted var species: String = ""
    @Persisted var birthDate: String = ""
    @Persisted var weight: String = ""
    @Persisted var sex: String = ""
    
    // 기념일 데이터
    @Persisted var anniversaryDatas = List<AnniversaryData>()
    
    // 알림 데이터
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

// 알림 데이터
class NotiData: Object {
    @Persisted var identifier: List<String>
    @Persisted var content: String
    @Persisted var memo: String
    @Persisted var notiDate: Date
    @Persisted var weekDays: List<Int>
    @Persisted var daysString: String
    @Persisted var repeatTypeDisplayName: String
    @Persisted var notiUIImageData: Data?
    
    convenience init(identifier: List<String>, content: String, memo: String, notiDate: Date, weekDays: List<Int>, daysString: String, repeatTypeDisplayName: String, notiUIImageData: Data? = nil) {
        self.init()
        self.identifier = identifier
        self.content = content
        self.memo = memo
        self.notiDate = notiDate
        self.weekDays = weekDays
        self.daysString = daysString
        self.repeatTypeDisplayName = repeatTypeDisplayName
        self.notiUIImageData = notiUIImageData
    }
}
