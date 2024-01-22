import SwiftUI

struct OnboardingSecondView: View {
    var body: some View {
        VStack {
            Text("밥 시간, 물 갈아주기 등 알림을 통해 관리 해보세요!")
                .foregroundColor(.gray)
                .font(.system(size: 25, weight: .bold))
                .lineLimit(nil)
            
            Image(systemName: "bell.fill")
                .resizable()
                .frame(width: 170, height: 180)
                .padding(.top, 70)
                .foregroundStyle(Color("PeachColor"))
            Spacer()
        }
        .padding(EdgeInsets(top: 70, leading: 6, bottom: 6, trailing: 6))
    }
}

#Preview {
    OnboardingSecondView()
}
