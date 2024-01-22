import SwiftUI

struct OnboardingThirdView: View {
    var body: some View {
        VStack {
            Text("반려동물의 특별한 기념일을 알려줄수도 있답니다!")
                .foregroundColor(.gray)
                .font(.system(size: 25, weight: .bold))
                .lineLimit(nil)
            
            Image(systemName: "party.popper.fill")
                .resizable()
                .frame(width: 170, height: 180)
                .padding(.top, 70)
                .foregroundStyle(Color("BlueColor"))
            
            Spacer()
            
            HStack {
                Spacer() 
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 8))
        }
        .padding(EdgeInsets(top: 70, leading: 6, bottom: 6, trailing: 6))
    }
}
