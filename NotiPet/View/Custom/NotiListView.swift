import SwiftUI

struct NotiListView: View {
    @StateObject var notiData: NotiData
    
    var body: some View {
        VStack {
            Group {
                HStack {
                    Text("\(notiData.notiDate.dateToTime())")
                    Spacer()
                    VStack {
                        Text(notiData.daysString)
                        Text("\(notiData.notiDate.convertDatePlusDay())")
                    }
                }
                HStack {
                    Text(notiData.content)
                    Spacer()
                }
                HStack {
                    Text(notiData.memo)
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
