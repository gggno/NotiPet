import SwiftUI

struct NotiListView: View {
    @StateObject var notiData: NotiData
    
    var body: some View {
        VStack {
            Group {
                HStack {
                    Text(notiData.notiDate.onlyTime())
                        .foregroundStyle(.gray)
                        .font(.system(size: 20, weight: .medium))
                    Spacer()
                    VStack {
                        Text(notiData.daysString)
                        Text("\(notiData.notiDate.convertDatePlusDay())")
                    }
                    .foregroundStyle(.gray)
                    .font(.system(size: 15, weight: .light))
                }
                HStack {
                    Text(notiData.content)
                        .font(.system(size: 18, weight: .medium))
                    Spacer()
                }
                .padding(.bottom, 2)
                HStack {
                    Text(notiData.memo)
                        .font(.system(size: 13, weight: .medium))
                    Spacer()
                }
                if let imageData = notiData.notiUIImageData {
                    let uiImage = UIImage(data: imageData)
                    Image(uiImage: uiImage!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            
        }
        
    }
}
