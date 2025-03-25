//
//  ArticleSortingService.swift
//  Purple
//
//  Created by Ben Booth on 3/19/25.
//
import Foundation

// ✅ Update sorting period to match Reddit API
enum SortingPeriod: String, CaseIterable, Identifiable {
    case today = "Today"
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case allTime = "All Time"

    var id: String { self.rawValue }

    // Convert to Reddit’s API query format
    func toRedditParameter() -> String {
        switch self {
        case .today: return "day"
        case .thisWeek: return "week"
        case .thisMonth: return "month"
        case .allTime: return "all"
        }
    }
}

class ArticleSortingService: ObservableObject {
    @Published var selectedPeriod: SortingPeriod = .thisMonth
    private var lastFetchedPeriod: SortingPeriod?

    func shouldRefetchFromAPI(for newPeriod: SortingPeriod) -> Bool {
        guard let lastPeriod = lastFetchedPeriod else { return true }
        return lastPeriod != newPeriod
    }

    func setLastFetchedPeriod(_ period: SortingPeriod) {
        self.lastFetchedPeriod = period
    }
}

