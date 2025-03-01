import GoogleMobileAds
import SwiftUI

struct NativeContentView: View {
    @EnvironmentObject private var nativeAdViewModel: NativeAdViewModel
    @State private var adSecond = 3
    @Binding var isShowingAdScreen: Bool
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private var isOnNativeAd: Bool {
        return adSecond > -1
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                NativeAdView(nativeViewModel: nativeAdViewModel)
                    .frame(height: 100)
                
                Text(
                    nativeAdViewModel.nativeAd?.mediaContent.hasVideoContent == true
                    ? "Ad contains a video asset." : "Ad does not contain a video."
                )
                .frame(maxWidth: .infinity)
                .foregroundColor(.gray)
                .opacity(nativeAdViewModel.nativeAd == nil ? 0 : 1)
                
                Button("Refresh Ad") {
                    refreshAd()
                }
                
                Text(
                    "SDK Version:"
                    + "\(GADGetStringFromVersionNumber(GADMobileAds.sharedInstance().versionNumber))")
            }
            .padding()
            .onAppear {
                refreshAd()
            }
            .onReceive(timer, perform: { _ in
                if isOnNativeAd {
                    adSecond -= 1
                }
            })
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        isShowingAdScreen = false
                    }, label: {
                        Text(isOnNativeAd ? "\(adSecond)" : "닫기")
                    })
                    .disabled(isOnNativeAd)
                }
            }
        }
    }
    
    private func refreshAd() {
        nativeAdViewModel.refreshAd()
    }
}

struct NativeContentView_Previews: PreviewProvider {
    static var previews: some View {
        NativeContentView(isShowingAdScreen: .constant(true))
    }
}

struct NativeAdView: UIViewRepresentable {
    
    typealias UIViewType = GADNativeAdView
    //typealias UIViewType = NativeAdTestView
    @ObservedObject var nativeViewModel: NativeAdViewModel
    
    func makeUIView(context: Context) -> GADNativeAdView {
        return Bundle.main.loadNibNamed(
            "NativeAdView",
            owner: nil,
            options: nil)?.first as! GADNativeAdView
    }
    
    func updateUIView(_ nativeAdView: GADNativeAdView, context: Context) {
        guard let nativeAd = nativeViewModel.nativeAd else { return }
        
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        
        (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(from: nativeAd.starRating)
        
        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
        
        (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
        
        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        
//        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        
        // In order for the SDK to process touch events properly, user interaction should be disabled.
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        
        // Associate the native ad view with the native ad object. This is required to make the ad clickable.
        // Note: this should always be done after populating the ad views.
        nativeAdView.nativeAd = nativeAd
    }
    
    //    func makeUIView(context: Context) -> NativeAdTestView {
    //        return NativeAdTestView()
    //    }
    //
    //    func updateUIView(_ uiView: NativeAdTestView, context: Context) {
    //        guard let nativeAd = nativeViewModel.nativeAd else { return }
    //
    //        uiView.iconImageView.image = nativeAd.icon?.image
    //
    //        uiView.headlineLabel.text = nativeAd.headline
    //
    //        uiView.advertiserLabel.text = nativeAd.advertiser
    //
    //        uiView.ratingImageView.image = imageOfStars(from: nativeAd.starRating)
    //
    //        uiView.bodyLabel.text = nativeAd.body
    //
    //        uiView.adMediaView.mediaContent = nativeAd.mediaContent
    //
    //        uiView.priceLabel.text = nativeAd.price
    //
    //        uiView.storeLabel.text = nativeAd.store
    //
    //        uiView.installButton.setTitle(nativeAd.callToAction, for: .normal)
    //        uiView.installButton.isUserInteractionEnabled = false
    //
    //        uiView.nativeAd = nativeAd
    //    }
    
    private func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
        guard let rating = starRating?.doubleValue else {
            return nil
        }
        if rating >= 5 {
            return UIImage(named: "stars_5")
        } else if rating >= 4.5 {
            return UIImage(named: "stars_4_5")
        } else if rating >= 4 {
            return UIImage(named: "stars_4")
        } else if rating >= 3.5 {
            return UIImage(named: "stars_3_5")
        } else {
            return nil
        }
    }
}
