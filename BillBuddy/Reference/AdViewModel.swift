//
//  AdViewModel.swift
//  BillBuddy
//
//  Created by 김유진 on 1/13/24.
//
import GoogleMobileAds
import Foundation

final class AdViewModel: NSObject, ObservableObject, GADNativeAdLoaderDelegate {
    @Published var ad: GADNativeAd?
    private var adLoader: GADAdLoader!
    
    func refreshAd() {
        adLoader = GADAdLoader(
            adUnitID:
                "ca-app-pub-3940256099942544/3986624511",
            rootViewController: nil,
            adTypes: [.native], options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive ad: GADNativeAd) {
        self.ad = ad
        ad.delegate = self
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("\(adLoader) failed with error: \(error.localizedDescription)")
    }
}

// MARK: - GADNativeAdDelegate implementation
extension AdViewModel: GADNativeAdDelegate {
    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdWillPresentScreen(_ nativeAd: GADNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdWillDismissScreen(_ nativeAd: GADNativeAd) {
        print("\(#function) called")
    }
    
    func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
        print("\(#function) called")
    }
}
