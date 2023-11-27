import SwiftUI
import Combine
import RealmSwift

class PetInfoViewModel: ObservableObject {
    
    var subscriptions = Set<AnyCancellable>()
    
    @Published var petName: String = ""
    @Published var species: String = ""
    @Published var birthDate: String = Date().convertDate()
    @Published var weight: String = ""
    @Published var sex: String = ""
    
    @Published var petNameMessage: String = ""
    @Published var speciesMessage: String = ""
    @Published var weightMessage: String = ""
    @Published var isValidation: Bool = false
    
    var validPetNamePublisher: AnyPublisher<Bool, Never> {
        $petName
            .map{$0.count >= 1}
            .eraseToAnyPublisher()
    }
    
    var validSpeciesPublisher: AnyPublisher<Bool, Never> {
        $species
            .map{$0.count >= 1}
            .eraseToAnyPublisher()
    }
    
    var validWeightPublisher: AnyPublisher<Bool, Never> {
        $weight
            .map{String($0).count >= 1}
            .eraseToAnyPublisher()
    }
    
    var validConfirmPublisher: AnyPublisher<Bool, Never> {
        Publishers
            .CombineLatest3(validPetNamePublisher, validSpeciesPublisher, validWeightPublisher)
            .map{$0 && $1 && $2}
            .eraseToAnyPublisher()
    }
    
    let petInfo = PetInfo()
    let realm = try! Realm()
    
    init() {
        // 로컬 디비 데이터 확인
        dataConfirm()
        
        validPetNamePublisher
            .receive(on: RunLoop.main)
            .map{$0 ? "" : "한 글자 이상 입력해주세요"}
            .assign(to: \.petNameMessage, on: self)
            .store(in: &subscriptions)
            
        validSpeciesPublisher
            .receive(on: RunLoop.main)
            .map{$0 ? "" : "한 글자 이상 입력해주세요"}
            .assign(to: \.speciesMessage, on: self)
            .store(in: &subscriptions)
        
        validWeightPublisher
            .receive(on: RunLoop.main)
            .map{$0 ? "" : "한 글자 이상 입력해주세요"}
            .assign(to: \.weightMessage, on: self)
            .store(in: &subscriptions)
        
        
        validConfirmPublisher
            .receive(on: RunLoop.main)
            .map{$0 ? true : false}
            .assign(to: \.isValidation, on: self)
            .store(in: &subscriptions)
        
        $petName
            .print("petName")
            .sink(receiveValue: { _ in
            }).store(in: &subscriptions)
        
        $species
            .print("species")
            .sink(receiveValue: { _ in
            }).store(in: &subscriptions)
        
        $birthDate
            .print("birthDate")
            .sink(receiveValue: { _ in
            }).store(in: &subscriptions)
        
        $weight
            .print("weight")
            .sink(receiveValue: { _ in
            }).store(in: &subscriptions)
        
        $sex
            .print("sex")
            .sink(receiveValue: { _ in
            }).store(in: &subscriptions)
    }
    
    // 정보가 있는지 확인 있으면 화면에 출력하기 위한 용도
    func dataConfirm() {
        if let data = realm.objects(PetInfo.self).first {
            petName = data.petName
            species = data.species
            birthDate = data.birthDate
            weight = data.weight
            sex = data.sex
        }
    }
    
    // 펫 정보를 로컬DB에 저장, 갱신
    func infoSave() {
        if let data = realm.objects(PetInfo.self).first {
            try! realm.write {
                data.petName = petName
                data.species = species
                data.birthDate = birthDate
                data.weight = weight
                data.sex = sex
            }
        } else {
            try! realm.write {
                petInfo.petName = petName
                petInfo.species = species
                petInfo.birthDate = birthDate
                petInfo.weight = weight
                petInfo.sex = sex
                
                realm.add(petInfo)
            }
        }
    }
    
}
