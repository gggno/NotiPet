import SwiftUI

struct OnboardingFirstView: View {
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("우리의 반려동물을 체계적으로 관리하며, 그들의 건강과 행복을 책임지는 편리한 서비스")
                    .lineLimit(nil)
                    .foregroundColor(.gray)
                
                Text("알림펫")
                    .font(.system(size: 50))
                    .bold()
            }
            
            Image(systemName: "pawprint.circle.fill")
                .resizable()
                .frame(width: 180, height: 180)
                .padding(.top, 70)
            Spacer()
                
        }
        .padding(EdgeInsets(top: 70, leading: 6, bottom: 6, trailing: 6))
    }

}

#Preview {
    OnboardingFirstView()
}
