class Ingredient {
  final String nom;
  final double quantite;
  final double prixUnitaire;

  Ingredient({
    required this.nom,
    required this.quantite,
    required this.prixUnitaire,
  });

  double get prixTotal => quantite * prixUnitaire;

  Map<String, dynamic> toMap() {
    return {'nom': nom, 'quantite': quantite, 'prixUnitaire': prixUnitaire};
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      nom: map['nom'],
      quantite: map['quantite'],
      prixUnitaire: map['prixUnitaire'],
    );
  }
}

class Recette {
  final String nomRecette;
  final String description;
  final String heuresDePreparation;
  final List<Ingredient> ingredients;
  String commentaire;
  final String categorie;
  bool favorite;

  Recette({
    required this.nomRecette,
    required this.description,
    required this.heuresDePreparation,
    required this.ingredients,
    required this.commentaire,
    required this.categorie,
    this.favorite = false,
  });

  double get prixTotal {
    double total = 0.0;
    for (var ingredient in ingredients) {
      double prixAuKg = ingredient.prixUnitaire * 10;
      total += ingredient.quantite * prixAuKg;
    }
    return total;
  }

  Map<String, dynamic> toMap() {
    return {
      'nomRecette': nomRecette,
      'description': description,
      'heuresDePreparation': heuresDePreparation,
      'ingredients':
          ingredients.map((ingredient) => ingredient.toMap()).toList(),
      'commentaire': commentaire,
      'categorie': categorie,
      'favorite': favorite,
    };
  }

  factory Recette.fromMap(Map<String, dynamic> map) {
    var ingredientsList = List<Ingredient>.from(
      map['ingredients'].map(
        (ingredientMap) => Ingredient.fromMap(ingredientMap),
      ),
    );

    return Recette(
      nomRecette: map['nomRecette'],
      description: map['description'],
      heuresDePreparation: map['heuresDePreparation'],
      ingredients: ingredientsList,
      commentaire: map['commentaire'],
      categorie: map['categorie'],
      favorite: map['favorite'] ?? false,
    );
  }
}
