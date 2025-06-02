enum CropCategory {
  cereals('Cereals'),
  legumes('Legumes'),
  rootsAndTubers('Roots and Tubers'),
  fruits('Fruits'),
  vegetables('Vegetables'),
  cashCrops('Cash Crops'),
  spicesAndHerbs('Spices and Herbs'),
  oilCrops('Oil Crops'),
  horticulturalCrops('Horticultural Crops'),
  others('Others');

  final String label;

  const CropCategory(this.label);
}

extension CropCategoryExtension on String {
  CropCategory toCropCategoryEnum() {
    switch (toLowerCase()) {
      case 'cereals':
        return CropCategory.cereals;
      case 'legumes':
        return CropCategory.legumes;
      case 'roots and tubers':
        return CropCategory.rootsAndTubers;
      case 'fruits':
        return CropCategory.fruits;
      case 'vegetables':
        return CropCategory.vegetables;
      case 'cash crops':
        return CropCategory.cashCrops;
      case 'spices and herbs':
        return CropCategory.spicesAndHerbs;
      case 'oil crops':
        return CropCategory.oilCrops;
      case 'horticultural crops':
        return CropCategory.horticulturalCrops;
      case 'others':
      default:
        return CropCategory.others;
    }
  }
}

extension CropCategoryToString on CropCategory {
  String get string => label;
}
