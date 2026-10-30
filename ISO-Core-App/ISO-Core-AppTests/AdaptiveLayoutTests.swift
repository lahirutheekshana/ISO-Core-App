import XCTest
import SwiftUI
@testable import ISO_Core_App

final class AdaptiveLayoutTests: XCTestCase {
    
    func testRecipeGridUsesTwoColumnsOnCompactWidth() {
        let columns = AdaptiveLayout.recipeGridColumns(for: .compact)
        XCTAssertEqual(columns.count, 2)
    }
    
    func testRecipeGridUsesThreeColumnsOnRegularWidth() {
        let columns = AdaptiveLayout.recipeGridColumns(for: .regular)
        XCTAssertEqual(columns.count, 3)
    }
    
    func testRecipeGridDefaultsToTwoColumnsWhenSizeClassUnknown() {
        let columns = AdaptiveLayout.recipeGridColumns(for: nil)
        XCTAssertEqual(columns.count, 2)
    }
    
    func testLayoutMaxWidthsStayReadableOnLargeDisplays() {
        XCTAssertLessThanOrEqual(AdaptiveLayout.formMaxWidth, 520)
        XCTAssertLessThanOrEqual(AdaptiveLayout.contentMaxWidth, 900)
        XCTAssertLessThanOrEqual(AdaptiveLayout.detailMaxWidth, 800)
        XCTAssertLessThanOrEqual(AdaptiveLayout.tabBarMaxWidth, 600)
    }
}
