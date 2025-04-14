class Category {
  final String key; // pour la base de donnée et les assets
  final String title;
  final String description;

  const Category({
    required this.key,
    required this.title,
    required this.description,
  });
}

class RecipeCategories {
  static const List<Category> all = [
    Category(
      key: 'entrees',
      title: 'Entrées',
      description: 'Salades, tartares, bruschettas, soupes, etc.',
    ),
    Category(
      key: 'plats_principaux',
      title: 'Plats principaux',
      description: 'Viandes, poissons, pâtes, riz, gratins, etc.',
    ),
    Category(
      key: 'desserts',
      title: 'Desserts',
      description: 'Gâteaux, tartes, crèmes, glaces, etc.',
    ),
    Category(
      key: 'patisseries',
      title: 'Pâtisseries',
      description: 'Viennoiseries, biscuits, macarons, etc.',
    ),
    Category(
      key: 'vegetarien_vegan',
      title: 'Végétarien/Végan',
      description: 'Plats sans viande ni produits animaux.',
    ),
    Category(
      key: 'cuisine_du_monde',
      title: 'Cuisine du monde',
      description: 'Recettes italiennes, asiatiques, mexicaines, etc.',
    ),
    Category(
      key: 'plats_rapides',
      title: 'Plats rapides et faciles',
      description: 'Idées pour repas express.',
    ),
    Category(
      key: 'healthy',
      title: 'Recettes healthy',
      description: 'Options légères et équilibrées.',
    ),
    Category(
      key: 'boulangerie',
      title: 'Boulangerie',
      description: 'Pains, brioches, focaccias, etc.',
    ),
    Category(
      key: 'boissons',
      title: 'Boissons et cocktails',
      description: 'Smoothies, thés, mocktails, etc.',
    ),
  ];

  static Category? getByKey(String key) {
    try {
      return all.firstWhere((c) => c.key == key);
    } catch (e) {
      return null;
    }
  }

  static String? getTitleByKey(String key) {
    final category = getByKey(key);
    return category?.title;
  }

  static String? getDescriptionByKey(String key) {
    final category = getByKey(key);
    return category?.description;
  }
}
