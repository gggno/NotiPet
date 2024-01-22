import SwiftUI

struct NoDataView: View {
    var body: some View {
        Text("알림 정보가 없습니다. 알림을 추가해주세요.")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NoDataView()
}
