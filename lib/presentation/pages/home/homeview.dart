// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:reciply/core/constants/app_colors.dart';
import 'package:reciply/core/constants/app_text_styles.dart';

import 'package:reciply/data/models/recette_model.dart';
import 'package:reciply/data/models/category_model.dart';

import 'package:reciply/presentation/pages/home/recette/recette_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentTabIndex = 0;

  final List<Widget> _tabs = [
    const _AllRecipesTab(),
    const _FavoriteRecipesTab(),
    const ShoppingListTab(),
    const _SearchTab(),
  ];

  void changeTab(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text('Reciply', style: AppTextStyle.reciplyLogo),
        ),
        actions: [
          if (_currentTabIndex == 2)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _confirmClearCart(context),
            ),
          IconButton(
            icon: const Icon(Icons.person, size: 28),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: _tabs[_currentTabIndex],
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: changeTab,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoris'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Panier',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
        ],
      ),
    );
  }

  Widget? _buildFAB() {
    switch (_currentTabIndex) {
      case 0:
      case 3:
      case 4:
        return FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/addrecetteview'),
          child: const Icon(Icons.add),
        );
      case 2:
        return FloatingActionButton(
          onPressed: () => _showAddIngredientDialog(context),
          child: const Icon(Icons.add),
        );
      default:
        return null;
    }
  }

  Future<void> _confirmClearCart(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Vider le panier'),
            content: const Text(
              'Êtes-vous sûr de vouloir vider tout votre panier ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Vider', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      Provider.of<RecetteViewModel>(context, listen: false).viderPanier();
    }
  }

  void _showAddIngredientDialog(BuildContext context) {
    final viewModel = Provider.of<RecetteViewModel>(context, listen: false);
    final nomController = TextEditingController();
    final quantiteController = TextEditingController(text: '1');
    final prixController = TextEditingController(text: '1000');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ajouter un ingrédient'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                  autofocus: true,
                ),
                TextField(
                  controller: quantiteController,
                  decoration: const InputDecoration(labelText: 'Quantité (kg)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: prixController,
                  decoration: const InputDecoration(
                    labelText: 'Prix unitaire (Ar)',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nomController.text.isNotEmpty &&
                      quantiteController.text.isNotEmpty &&
                      prixController.text.isNotEmpty) {
                    viewModel.ajouterIngredientManuellement(
                      Ingredient(
                        nom: nomController.text,
                        quantite: double.parse(quantiteController.text),
                        prixUnitaire: double.parse(prixController.text),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Ajouter'),
              ),
            ],
          ),
    );
  }
}

class _AllRecipesTab extends StatelessWidget {
  const _AllRecipesTab();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RecetteViewModel>(context);

    return StreamBuilder<List<MapEntry<String, Recette>>>(
      stream: viewModel.recettesUtilisateurStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Aucune recette ajoutée"));
        }

        return _RecipeGrid(recipes: snapshot.data!);
      },
    );
  }
}

class _FavoriteRecipesTab extends StatelessWidget {
  const _FavoriteRecipesTab();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RecetteViewModel>(context);

    return StreamBuilder<List<MapEntry<String, Recette>>>(
      stream: viewModel.recettesUtilisateurStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Aucune recette disponible"));
        }

        final favorites =
            snapshot.data!.where((r) => r.value.favorite).toList();

        if (favorites.isEmpty) {
          return const Center(child: Text("Aucune recette favorite"));
        }

        return _RecipeGrid(recipes: favorites);
      },
    );
  }
}

class _RecipeGrid extends StatelessWidget {
  final List<MapEntry<String, Recette>> recipes;

  const _RecipeGrid({required this.recipes});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final entry = recipes[index];
        return _RecipeCard(recipeId: entry.key, recipe: entry.value);
      },
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final String recipeId;
  final Recette recipe;

  const _RecipeCard({required this.recipeId, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final category = RecipeCategories.getByKey(recipe.categorie);
    final imagePath =
        category != null
            ? 'assets/images/recettes/${category.key}.jpg'
            : 'assets/images/recettes/default.jpg';

    return GestureDetector(
      onTap:
          () => Navigator.pushNamed(
            context,
            '/recetteDetail',
            arguments: {'recette': recipe, 'recetteId': recipeId},
          ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                      child: Center(
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder:
                              (_, __, ___) => Image.asset(
                                'assets/images/recettes/default.jpg',
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                        ),
                      ),
                    ),
                    if (recipe.favorite)
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(Icons.favorite, color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.nomRecette,
                    style: AppTextStyle.body.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category?.title ?? recipe.categorie,
                    style: AppTextStyle.body.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShoppingListTab extends StatelessWidget {
  const ShoppingListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecetteViewModel>(
      builder: (context, viewModel, _) {
        return StreamBuilder<List<Ingredient>>(
          stream: viewModel.panierStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Votre panier est vide'));
            }

            final ingredients = snapshot.data!;
            final total = ingredients.fold<double>(
              0,
              (sum, ing) => sum + ing.quantite * ing.prixUnitaire,
            );

            return Column(
              children: [
             
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${total.toStringAsFixed(2)} Ar',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Séparateur visuel
                const Divider(height: 1, thickness: 1),
                // La liste des ingrédients
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = ingredients[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(ingredient.nom),
                          subtitle: Text('${ingredient.quantite} kg'),
                          trailing: Text(
                            '${(ingredient.quantite * ingredient.prixUnitaire).toStringAsFixed(2)} Ar',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          leading: IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                            onPressed: () => viewModel.supprimerDuPanier(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SearchTab extends StatelessWidget {
  const _SearchTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Recherche en cours de développement"));
  }
}
