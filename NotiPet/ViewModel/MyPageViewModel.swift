import SwiftUI
import Combine
import RealmSwift

class MyPageViewModel: ObservableObject {
    
    @Published var petProfileUIImage: UIImage = UIImage(systemName: "pawprint.circle.fill")!
    @Published var petName: String = ""
    @Published var species: String = ""
    @Published var birthDate: String = Date().convertDate()
    @Published var weight: String = ""
    @Published var sex: String = ""
    
    let petInfo = PetInfo()
    let realm = try! Realm()
    
    init() {
        getInfoFromDB()
        NotificationCenter.default.addObserver(self, selector: #selector(recievedDatas(_:)), name: NSNotification.Name("PetInfosData"), object: nil)
    }
    
    // 로컬 DB에서 가져와 처음 데이터 저장
    func getInfoFromDB() {
        print("MyPageViewModel - getInfoFromDB() called")
        if let data = realm.objects(PetInfo.self).first {
            print("getInfoFromDB() - 로컬디비에 정보가 있다.")
            if let imageData = data.petProfileImageData {
                petProfileUIImage = UIImage(data: imageData)!
            }
            petName = data.petName
            species = data.species
            birthDate = data.birthDate
            weight = data.weight
            sex = data.sex
        }
    }
    
    // 데이터가 변경될 시 감지 후 업데이트
    @objc func recievedDatas(_ notification: NSNotification) {
        if let userInfo = notification.userInfo,
           let petProfileImage = userInfo["petProfileUIImage"] as? UIImage,
           let petName = userInfo["petName"] as? String,
           let species = userInfo["species"] as? String,
           let birthDate = userInfo["birthDate"] as? String,
           let weight = userInfo["weight"] as? String,
           let sex = userInfo["sex"] as? String {
            self.petProfileUIImage = petProfileImage
            self.petName = petName
            self.species = species
            self.birthDate = birthDate
            self.weight = weight
            self.sex = sex
        }
    }
    
}
