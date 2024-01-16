import SwiftUI

struct PetProfileView: View {
    @Binding var petProfileUIImage: UIImage?
    @Binding var petName: String
    @Binding var birthDate: String
    @Binding var sex: String
    
    var body: some View {
        VStack {
            HStack {
                if let image = petProfileUIImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        .frame(width: 100, height: 100)
                } else {
                    Circle()
                        .fill()
                        .overlay(
                            Text("이미지 추가")
                                .foregroundColor(.blue)
                        )
                        .frame(width: 100, height: 100)
                }
                VStack(alignment: .leading) {
                    HStack {
                        Image(uiImage: UIImage(named: sex == "남아" ? "Male" : "Female")!)
                        Text(petName)
                            .lineLimit(1)
                    }
                    Text("함께한지 \(Int(birthDate.dayConvertDate())! + 1)일")
                        .lineLimit(1)
                }
            }
        }
        .listRowSeparator(.hidden)
        Spacer()
            .frame(height: 150)
    }
}
