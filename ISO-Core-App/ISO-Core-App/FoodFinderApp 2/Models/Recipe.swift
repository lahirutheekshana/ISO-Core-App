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
    
    // Ingredients (The API returns these individually rather than an array)
    let strIngredient1: String?
    let strIngredient2: String?
    let strIngredient3: String?
    let strIngredient4: String?
    let strIngredient5: String?
    
    // Measures
    let strMeasure1: String?
    let strMeasure2: String?
    let strMeasure3: String?
    let strMeasure4: String?
    let strMeasure5: String?
    
    var id: String { idMeal }
    
    // Helper to extract a combined list of non-empty ingredients and measures
    var ingredients: [(ingredient: String, measure: String)] {
        var result: [(String, String)] = []
        
        let ingredientProperties = [strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5]
        let measureProperties = [strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5]
        
        for i in 0..<ingredientProperties.count {
            if let ingredient = ingredientProperties[i], !ingredient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               let measure = measureProperties[i], !measure.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                result.append((ingredient, measure))
            }
        }
        
        return result
    }
}
