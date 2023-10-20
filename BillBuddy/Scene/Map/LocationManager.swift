//
//  LocationManager.swift
//  BillBuddyMapKit
//
//  Created by 이승준 on 10/5/23.
//

import Foundation
import CoreLocation
import MapKit

final class LocationManager: NSObject, ObservableObject {
    
    private let locationManager = CLLocationManager()
    
    @Published var mapView: MKMapView = .init()
    @Published var isChaging: Bool = false
    @Published var selectedAddress: String = ""
    @Published var selectedLatitude: Double = 0.0
    @Published var selectedLongitude: Double = 0.0
    
    private var userLocalcity: String = ""
    private var seletedPlace: MKAnnotation?
    
    override init() {
        super.init()
        configure()
        requestAuthorizqtion()
    }
    
    func configure() {
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    /// 위치 승인
    func requestAuthorizqtion() {
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            moveFocusOnUserLocation()
        case .notDetermined:
            locationManager.startUpdatingLocation()
            locationManager.requestAlwaysAuthorization()
        default: break
        }
    }
}
extension LocationManager {
    
    // MARK: - 사용자 위치로 포인터 이동
    func moveFocusOnUserLocation() {
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    // MARK: - 주소로 화면 이동
    func moveFocusChange(location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.01)
        
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - 주소로 검색
    func searchAddress(searchAddress: String){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchAddress) { [self] placeMarks, error in
            guard let placeMark = placeMarks?.first, let location = placeMark.location
            else {
                print("주소를 찾을 수 없습니다.")
                return
            }
            print("입력된 주소: \(searchAddress)")
            
            selectedAddress = searchAddress
            selectedLatitude = location.coordinate.latitude
            selectedLongitude = location.coordinate.longitude
            
            moveFocusChange(location: location.coordinate)
        }
    }
    
    // MARK: - 위도, 경도에 따른 주소 찾기
    func findAddr(location: CLLocation){
        let findLocation = location
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(findLocation, completionHandler: {(placemarks, error) in
            if let address: [CLPlacemark] = placemarks {
                var myAdd: String = ""
                if let area: String = address.last?.locality{
                    myAdd += area
                }
                
                if let name: String = address.last?.name {
                    myAdd += " "
                    myAdd += name
                }
                self.selectedAddress = myAdd
            }
        })
    }
    
    // MARK: - 커스텀한 어노테이션 셋팅
    func setAnnotations(filteredPayments: [Payment]) {
        mapView.removeAnnotations(mapView.annotations)
        
        for payment in filteredPayments {
            let pinIndex: Int = 1
            let customPinImage: UIImage = UIImage(named: "customPinImage")!
            let coordinate = CLLocationCoordinate2D(latitude: payment.address.latitude, longitude: payment.address.longitude)
            
            let pin = CustomAnnotation(pinIndex: pinIndex, customPinImage: customPinImage, coordinate: coordinate)
            mapView.addAnnotation(pin)
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways else { return }
        locationManager.requestLocation()
        moveFocusOnUserLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    // 현재 위치를 저장
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
}

extension LocationManager: MKMapViewDelegate {
    
    // 이동할 때마다 중앙 핀이 움직이게 하는
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        if !isChaging {
            DispatchQueue.main.async {
                self.isChaging = true
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        selectedLatitude = mapView.centerCoordinate.latitude
        selectedLongitude = mapView.centerCoordinate.longitude
        
        let location: CLLocation = CLLocation(latitude: selectedLatitude, longitude: selectedLongitude)
        
        findAddr(location: location)
        
        DispatchQueue.main.async {
            self.isChaging = false
        }
    }
    
    // MARK: - Annotaion Delegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard let annotation = annotation as? CustomAnnotation else {
            return nil
        }
        
        var annotationView = self.mapView.dequeueReusableAnnotationView(withIdentifier: CustomAnnotationView.identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: CustomAnnotationView.identifier)
            annotationView?.canShowCallout = false
            annotationView?.contentMode = .scaleAspectFit
            
        } else {
            annotationView?.annotation = annotation
        }
        
        // 커스텀 이미지
        let customPinImage: UIImage!
        let pinSize = CGSize(width: 46, height: 54)
        UIGraphicsBeginImageContext(pinSize)
        
        customPinImage = UIImage(named: "customPinImage")
        
        customPinImage.draw(in: CGRect(x: 0, y: 0, width: pinSize.width, height: pinSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        annotationView?.image = resizedImage
        
        
        return annotationView
    }
    
//    // 라인 뷰 제공
//    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        if let polyline = overlay as? MKPolyline {
//            let renderer = MKPolylineRenderer(polyline: polyline)
//            renderer.strokeColor = .red
//            renderer.lineWidth = 5
//            return renderer
//        }
//        return MKOverlayRenderer()
//    }
}

