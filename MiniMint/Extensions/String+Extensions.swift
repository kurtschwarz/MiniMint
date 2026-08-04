import Foundation

extension String {

  /// The family-name plural used in the header, e.g. "Smith" → "Smiths",
  /// "Jones" → "Joneses", "Fox" → "Foxes". Surnames keep a trailing "y"
  /// ("Kennedy" → "Kennedys"), so only an "es" suffix is added for sibilant
  /// endings; everything else just takes an "s".
  var pluralizedFamilyName: String {
    let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return trimmed }

    let sibilantEndings = ["s", "x", "z", "ch", "sh"]
    let lowercased = trimmed.lowercased()
    let suffix = sibilantEndings.contains(where: lowercased.hasSuffix) ? "es" : "s"

    return trimmed + suffix
  }

}
