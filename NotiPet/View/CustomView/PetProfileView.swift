import SwiftUI

struct PetProfileView: View {
    @Binding var petProfileUIImage: UIImage?
    @Binding var petName: String
    @Binding var birthDate: String
    @Binding var sex: String
    
    var body: some View {
        HStack(spacing: 15) {
            if let image = petProfileUIImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    .frame(width: 100, height: 100)
            } else {
                Image("PetBasicProfile")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    .frame(width: 100, height: 100)
            }
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(uiImage: UIImage(named: sex == "남아" ? "Male" : "Female")!)
                        .cornerRadius(5)
                    Text(petName)
                        .lineLimit(1)
                        .font(.system(size: 20, weight: .bold))
                }
                Text("함께한지 \((Int(birthDate.dayConvertDate()) ?? 0) + 1)일")
                    .lineLimit(1)
                    .font(.system(size: 15, weight: .regular))
            }
        }
        .listRowSeparator(.hidden)
    }
}
