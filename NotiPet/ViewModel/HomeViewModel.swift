import Foundation
import Combine
import SwiftUI
import RealmSwift

class HomeViewModel: ObservableObject {
    
    // 펫 정보
    @Published var petProfileUIImage: UIImage?
    @Published var petName: String = ""
    @Published var birthDate: String = ""
    @Published var sex: String = ""
    
    let petInfo = PetInfo()
    let realm = try! Realm()
    
    init() {
        // 처음 켰을 때 로컬 DB에서 데이터 받아오기
        getInfoFromData()
        
        // 펫 정보 변경 시 데이터 업데이트
        NotificationCenter.default.addObserver(self, selector: #selector(recievedPetInfoData(_:)), name: NSNotification.Name("PetInfosData"), object: nil)
        
    }
    
    func getInfoFromData() {
        print("HomeViewModel - getInfoFromData() called")
        
        if let allData = realm.objects(PetInfo.self).first {
            if let imageData = allData.petProfileImageData {
                petProfileUIImage = UIImage(data: imageData)
            }
            petName = allData.petName
            birthDate = allData.birthDate
            sex = allData.sex
        }
    }
    
    @objc func recievedPetInfoData(_ notification: NSNotification) {
        print("HomeViewModel - recievedPetInfoData() called")
        
        if let userInfo = notification.userInfo,
           let petName = userInfo["petName"] as? String,
           let birthDate = userInfo["birthDate"] as? String,
           let sex = userInfo["sex"] as? String {

            if let petProfileImage = userInfo["petProfileUIImage"] as? UIImage {
                self.petProfileUIImage = petProfileImage
            } else {
                self.petProfileUIImage = nil
            }
            self.petName = petName
            self.birthDate = birthDate
            self.sex = sex
        }
        
    }
    
}

