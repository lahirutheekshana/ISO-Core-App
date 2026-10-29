import Foundation

struct MealResponse: Codable {
    let meals: [Recipe]?
}

struct Recipe: Codable, Identifiable {
    let idMeal: String
    let strMeal: String
    let strCategory: String?
    let strArea: String?
    let strInstructions: String?
    let strMealThumb: String?
    let strYoutube: String?
    let strTags: String?
    
    // Ingredients (TheMealDB API returns 20 individual ingredients)
    let strIngredient1: String?
    let strIngredient2: String?
    let strIngredient3: String?
    let strIngredient4: String?
    let strIngredient5: String?
    let strIngredient6: String?
    let strIngredient7: String?
    let strIngredient8: String?
    let strIngredient9: String?
    let strIngredient10: String?
    let strIngredient11: String?
    let strIngredient12: String?
    let strIngredient13: String?
    let strIngredient14: String?
    let strIngredient15: String?
    let strIngredient16: String?
    let strIngredient17: String?
    let strIngredient18: String?
    let strIngredient19: String?
    let strIngredient20: String?
    
    // Measures (TheMealDB API returns 20 individual measures)
    let strMeasure1: String?
    let strMeasure2: String?
    let strMeasure3: String?
    let strMeasure4: String?
    let strMeasure5: String?
    let strMeasure6: String?
    let strMeasure7: String?
    let strMeasure8: String?
    let strMeasure9: String?
    let strMeasure10: String?
    let strMeasure11: String?
    let strMeasure12: String?
    let strMeasure13: String?
    let strMeasure14: String?
    let strMeasure15: String?
    let strMeasure16: String?
    let strMeasure17: String?
    let strMeasure18: String?
    let strMeasure19: String?
    let strMeasure20: String?
    
    var id: String { idMeal }
    
    // Helper to extract a combined list of non-empty ingredients and measures
    var ingredients: [(ingredient: String, measure: String)] {
        var result: [(ingredient: String, measure: String)] = []
        
        let ingredientProperties = [
            strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5,
            strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10,
            strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15,
            strIngredient16, strIngredient17, strIngredient18, strIngredient19, strIngredient20
        ]
        let measureProperties = [
            strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5,
            strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10,
            strMeasure11, strMeasure12, strMeasure13, strMeasure14, strMeasure15,
            strMeasure16, strMeasure17, strMeasure18, strMeasure19, strMeasure20
        ]
        
        for i in 0..<min(ingredientProperties.count, measureProperties.count) {
            if let ingredient = ingredientProperties[i]?.trimmingCharacters(in: .whitespacesAndNewlines),
               !ingredient.isEmpty {
                let measure = measureProperties[i]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                result.append((ingredient: ingredient, measure: measure))
            }
        }
        
        return result
    }
    
    // Split single instruction string from API into distinct step lines
    var instructionSteps: [String] {
        guard let instructions = strInstructions, !instructions.isEmpty else { return [] }
        return instructions
            .components(separatedBy: CharacterSet.newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
