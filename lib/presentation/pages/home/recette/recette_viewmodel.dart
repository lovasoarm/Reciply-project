import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../data/models/recette_model.dart';
import '../../../../core/services/firebase/services.dart';

class RecetteViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Services _authService;
  final List<Ingredient> _panier = [];
  List<MapEntry<String, Recette>> _recettes = [];

  RecetteViewModel(this._authService) {
    // Charger le panier au démarrage
    chargerPanierDepuisFirestore();

    // Écouter les changements de recettes
    recettesUtilisateurStream().listen((recettes) {
      _recettes = recettes;
    });
  }

  List<Ingredient> get panier => _panier;

  double get totalPanier {
    return _panier.fold(0, (total, ingredient) {
      return total + (ingredient.quantite * ingredient.prixUnitaire);
    });
  }

  //Méthode pour obtenir une recette par son ID
  Recette? getRecetteById(String id) {
    try {
      final entry = _recettes.firstWhere((entry) => entry.key == id);
      return entry.value;
    } catch (e) {
      debugPrint('Recette non trouvée avec l\'id $id: $e');
      return null;
    }
  }

  // Ajouter une recette
  Future<void> ajouterRecette(Recette recette) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('recettes')
        .add(recette.toMap());
  }

  Future<void> modifierRecette(String recetteId, Recette recette) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('recettes')
        .doc(recetteId)
        .set(recette.toMap());
  }

  Future<void> supprimerRecette(String recetteId) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('recettes')
        .doc(recetteId)
        .delete();
  }

  Stream<List<MapEntry<String, Recette>>> recettesUtilisateurStream() {
    final user = _authService.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('recettes')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return MapEntry(doc.id, Recette.fromMap(doc.data()));
          }).toList();
        });
  }

  Future<void> toggleFavorite(String recetteId, bool isFavorite) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('recettes')
        .doc(recetteId)
        .update({'favorite': isFavorite});
  }

  Future<void> saveComment(String recetteId, String commentaire) async {
    final user = _authService.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('recettes')
        .doc(recetteId)
        .update({'commentaire': commentaire});
  }

  // Méthodes pour la gestion du panier
  void ajouterAuPanier(List<Ingredient> ingredients) {
    for (final ingredient in ingredients) {
      final existingIndex = _panier.indexWhere(
        (i) => i.nom.toLowerCase() == ingredient.nom.toLowerCase(),
      );

      if (existingIndex >= 0) {
        _panier[existingIndex] = Ingredient(
          nom: _panier[existingIndex].nom,
          quantite: _panier[existingIndex].quantite + ingredient.quantite,
          prixUnitaire: ingredient.prixUnitaire,
        );
      } else {
        _panier.add(ingredient);
      }
    }

    enregistrerPanierFirestore();
    notifyListeners();
  }

  void ajouterIngredientManuellement(Ingredient ingredient) {
    final existingIndex = _panier.indexWhere(
      (i) => i.nom.toLowerCase() == ingredient.nom.toLowerCase(),
    );

    if (existingIndex >= 0) {
      _panier[existingIndex] = Ingredient(
        nom: _panier[existingIndex].nom,
        quantite: _panier[existingIndex].quantite + ingredient.quantite,
        prixUnitaire: ingredient.prixUnitaire,
      );
    } else {
      _panier.add(ingredient);
    }

    enregistrerPanierFirestore();
    notifyListeners();
  }

  void supprimerDuPanier(int index) {
    _panier.removeAt(index);
    enregistrerPanierFirestore();
    notifyListeners();
  }

  void viderPanier() {
    _panier.clear();
    enregistrerPanierFirestore();
    notifyListeners();
  }

  Future<void> chargerPanierDepuisFirestore() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final docSnapshot =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('panier')
              .doc('panierUtilisateur')
              .get();

      if (docSnapshot.exists) {
        _panier.clear();
        final panierData = docSnapshot['ingredients'] as List<dynamic>;
        _panier.addAll(
          panierData.map(
            (ingredientData) => Ingredient(
              nom: ingredientData['nom'],
              quantite: ingredientData['quantite'],
              prixUnitaire: ingredientData['prixUnitaire'],
            ),
          ),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement du panier: $e');
    }
  }

  Future<void> enregistrerPanierFirestore() async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      final panierData =
          _panier
              .map(
                (ingredient) => {
                  'nom': ingredient.nom,
                  'quantite': ingredient.quantite,
                  'prixUnitaire': ingredient.prixUnitaire,
                },
              )
              .toList();

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('panier')
          .doc('panierUtilisateur')
          .set({
            'ingredients': panierData,
            'total': totalPanier,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du panier: $e');
    }
  }

  Stream<List<Ingredient>> panierStream() {
    final user = _authService.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('panier')
        .doc('panierUtilisateur')
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return [];

          final panierData = snapshot['ingredients'] as List<dynamic>;
          return panierData.map((ingredientData) {
            return Ingredient(
              nom: ingredientData['nom'],
              quantite: ingredientData['quantite'],
              prixUnitaire: ingredientData['prixUnitaire'],
            );
          }).toList();
        });
  }

  List<MapEntry<String, Recette>> searchRecipes(String query) {
    if (query.isEmpty) return [];

    return _recettes.where((entry) {
      return entry.value.nomRecette.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
