import Foundation
import RealmSwift

class PetInfo: Object {
    @Persisted var petName: String = ""
    @Persisted var species: String = ""
    @Persisted var birthDate: String = ""
    @Persisted var weight: String = ""
    @Persisted var sex: String = ""
}
