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
}

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
