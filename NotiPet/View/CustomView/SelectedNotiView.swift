import SwiftUI

struct SelectedNotiView: View {
    @Binding var selectedDate: Date
    @Binding var selectedNotiDatas: [NotiData]
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            Text(selectedDate.convertDatePlusDay())
                .font(.headline)
            
            if !selectedNotiDatas.isEmpty {
                ForEach(selectedNotiDatas, id: \.self) { notiData in
                    HStack {
                        Text(notiData.notiDate.onlyTime())
                            .foregroundStyle(.gray)
                            .font(.system(size: 13, weight: .light))
                        Spacer()
                        Text("\(notiData.content)")
                            .font(.system(size: 17, weight: .regular))
                    }
                    .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                    .frame(maxWidth: 300)
                    .frame(height: 70)
                    .lineLimit(1)
                }
                .background(Color("CreamColor"), in: RoundedRectangle(cornerRadius: 10))
            } else {
                Text("일정이 없습니다")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 70)
    }
}

