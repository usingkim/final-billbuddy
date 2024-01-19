//
//  TravelListViewModel.swift
//  BillBuddy
//
//  Created by 김유진 on 1/20/24.
//

import Foundation
import Combine

final class TravelListViewModel: ObservableObject {
    private var userTravelService: UserTravelService = UserTravelService()
    
    @Published var travels: [TravelCalculation] = []
    @Published var filteredTravels: [TravelCalculation] = []
    
    @Published var selectedTravel: TravelCalculation?
    @Published var selectedFilter: TravelFilter = .paymentInProgress
    
    @Published var isShowingEditSheet = false
    @Published var isPresentedDateView: Bool = false
    @Published var isPresentedMemeberView: Bool = false
    @Published var isPresentedSpendingView: Bool = false
    
    @Published var isFetchedFirst: Bool = false
    @Published var isFetchingList: Bool = true
    
    private var cancellables: Set<AnyCancellable> = []
    
    func fetchMyTravel(completion: @escaping ([UserTravel]) -> Void) {
        self.isFetchingList = true
        userTravelService.fetchAll()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching data: \(error.localizedDescription)")
                }
            } receiveValue: { travels in
                completion(travels)
            }
            .store(in: &cancellables)
        
        self.isFetchingList = false
    }
    
    func fetchAll(completion: @escaping ([TravelCalculation]) -> Void) {
        let travelService = TravelCalculationService()
        
        fetchMyTravel { myTravels in
            self.travels = []
            for (idx, travel) in myTravels.enumerated() {
                travelService.fetchTravel(travel: travel)
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            print("Error fetching data: \(error.localizedDescription)")
                        }
                    } receiveValue: { travel in
                        self.travels.append(travel)
                        if idx == myTravels.count - 1 {
                            self.travels.sort { t1, t2 in
                                t1.startDate < t2.startDate && t1.endDate < t2.endDate
                            }
                            completion(self.travels)
                        }
                        self.isFetchedFirst = true
                    }
                    .store(in: &self.cancellables)
            }
        }
    }
    
    func filterTravel() {
        switch selectedFilter {
        case .paymentInProgress:
            filteredTravels = travels.filter { travel in
                return !travel.isPaymentSettled
            }
        case .paymentSettled:
            filteredTravels = travels.filter { travel in
                return travel.isPaymentSettled
            }
        }
    }
}
