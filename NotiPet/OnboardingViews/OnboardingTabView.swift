import SwiftUI

struct OnboardingTabView: View {
    @Binding var onboarding: Bool
    
    var body: some View {
        TabView {
            OnboardingFirstView()
            OnboardingSecondView()
            OnboardingThirdView(onboarding: $onboarding)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .never))   // 인디게이터 배경 색상 해제
        .onAppear {     // 인디게이터 색상 변경 설정
            UIPageControl.appearance().currentPageIndicatorTintColor = .black
                UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.2)
        }
        .onDisappear {  // 인디게이터 색상 변경 해제
            UIPageControl.appearance().currentPageIndicatorTintColor = nil
            UIPageControl.appearance().pageIndicatorTintColor = nil
        }
    }
}

