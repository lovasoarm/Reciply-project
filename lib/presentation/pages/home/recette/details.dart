// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reciply/core/constants/app_colors.dart';
import 'package:reciply/core/constants/app_text_styles.dart';
import 'package:reciply/data/models/recette_model.dart';
import 'package:reciply/data/models/category_model.dart';
import 'package:reciply/presentation/pages/home/recette/recette_viewmodel.dart';

class DetailView extends StatefulWidget {
  final Recette recette;
  final String recetteId;

  const DetailView({super.key, required this.recette, required this.recetteId});

  @override
  _DetailViewState createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView> {
  late Recette recette;
  late String recetteId;
  late TextEditingController _commentaireController;
  bool _isSaving = false;
  bool _isEditingComment = false;

  @override
  void initState() {
    super.initState();
    recette = widget.recette;
    recetteId = widget.recetteId;
    _commentaireController = TextEditingController(text: recette.commentaire);
  }

  @override
  void dispose() {
    _commentaireController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RecetteViewModel>(context, listen: false);
    final category = RecipeCategories.getByKey(recette.categorie);
    final categoryImage =
        category != null
            ? 'assets/images/recettes/${category.key}.jpg'
            : 'assets/images/recettes/default.jpg';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                categoryImage,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Image.asset(
                      'assets/images/recettes/default.jpg',
                      fit: BoxFit.cover,
                    ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete, color: AppColors.white),
                onPressed: () => _confirmDelete(context, viewModel),
              ),
              IconButton(
                icon: Icon(
                  recette.favorite ? Icons.favorite : Icons.favorite_border,
                  color: AppColors.white,
                ),
                onPressed: () => _toggleFavorite(viewModel),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Titre et catégorie
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        recette.nomRecette,
                        style: AppTextStyle.stylish.copyWith(
                          fontSize: 24,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Chip(
                      backgroundColor: AppColors.accent.withAlpha(50),
                      label: Text(
                        category?.title ?? recette.categorie,
                        style: AppTextStyle.subtitle.copyWith(
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Description
                Text('Description', style: AppTextStyle.subtitle),
                const SizedBox(height: 8),
                Text(
                  recette.description,
                  style: AppTextStyle.body.copyWith(height: 1.6),
                ),
                const SizedBox(height: 24),

                // Temps de préparation
                _buildInfoRow(
                  icon: Icons.timer,
                  value: '${recette.heuresDePreparation} h',
                  label: 'Temps de préparation',
                ),
                const SizedBox(height: 30),

                // Ingrédients
                Text('Ingrédients', style: AppTextStyle.subtitle),
                const SizedBox(height: 12),
                ...recette.ingredients
                    .map((ingredient) => _buildIngredientCard(ingredient))
                    ,
                const SizedBox(height: 30),

                // Prix total
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Prix total estimé :', style: AppTextStyle.subtitle),
                      Text(
                        '${recette.prixTotal.toStringAsFixed(2)} Ar',
                        style: AppTextStyle.headline.copyWith(
                          fontSize: 20,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Section Commentaire
                _buildCommentSection(viewModel),
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    RecetteViewModel viewModel,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Supprimer la recette'),
            content: const Text(
              'Êtes-vous sûr de vouloir supprimer cette recette ? Cette action est irréversible.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (shouldDelete == true) {
      try {
        await viewModel.supprimerRecette(recetteId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recette supprimée avec succès')),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: ${e.toString()}'),
            ),
          );
        }
      }
    }
  }

  Widget _buildCommentSection(RecetteViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Commentaire', style: AppTextStyle.subtitle),
        const SizedBox(height: 8),

        if (recette.commentaire.isEmpty && !_isEditingComment)
          Column(
            children: [
              TextField(
                controller: _commentaireController,
                decoration: const InputDecoration(
                  hintText: 'Ajoutez votre commentaire ici...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _isSaving ? null : () => _saveComment(viewModel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isSaving
                              ? const CircularProgressIndicator(
                                color: AppColors.white,
                              )
                              : const Text(
                                'Enregistrer',
                                style: AppTextStyle.button,
                              ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _ajouterAuPanier(viewModel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Faire la course',
                        style: AppTextStyle.button,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        else if (recette.commentaire.isNotEmpty && !_isEditingComment)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(recette.commentaire, style: AppTextStyle.body),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _isEditingComment = true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Modifier', style: AppTextStyle.button),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => _ajouterAuPanier(viewModel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Faire la course',
                      style: AppTextStyle.button,
                    ),
                  ),
                ],
              ),
            ],
          )
        else if (_isEditingComment)
          Column(
            children: [
              TextField(
                controller: _commentaireController,
                decoration: const InputDecoration(
                  hintText: 'Modifiez votre commentaire...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _isSaving ? null : () => _saveComment(viewModel),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isSaving
                              ? const CircularProgressIndicator(
                                color: AppColors.white,
                              )
                              : const Text(
                                'Enregistrer',
                                style: AppTextStyle.button,
                              ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isEditingComment = false;
                          _commentaireController.text = recette.commentaire;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Annuler', style: AppTextStyle.button),
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyle.subtitle),
          ],
        ),
        Row(
          children: [
            Text(value, style: AppTextStyle.subtitle),
            const SizedBox(width: 12),
            Icon(Icons.access_time, color: AppColors.primary, size: 24),
          ],
        ),
      ],
    );
  }

  Widget _buildIngredientCard(Ingredient ingredient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.accent.withAlpha(50), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                ingredient.nom,
                style: AppTextStyle.body.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text('${ingredient.quantite} kg', style: AppTextStyle.body),
            const SizedBox(width: 16),
            Text(
              '${ingredient.prixUnitaire} Ar',
              style: AppTextStyle.body.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(RecetteViewModel viewModel) async {
    try {
      final newFavoriteStatus = !recette.favorite;
      setState(() {
        recette.favorite = newFavoriteStatus;
      });

      await viewModel.toggleFavorite(recetteId, newFavoriteStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newFavoriteStatus
                ? 'Recette ajoutée aux favoris'
                : 'Recette retirée des favoris',
          ),
          duration: const Duration(seconds: 1),
        ),
      );

      if (newFavoriteStatus) {
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Voir vos favoris'),
              action: SnackBarAction(
                label: 'Aller',
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        recette.favorite = !recette.favorite;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    }
  }

  Future<void> _saveComment(RecetteViewModel viewModel) async {
    if (_commentaireController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    try {
      await viewModel.saveComment(
        recetteId,
        _commentaireController.text.trim(),
      );
      setState(() {
        recette.commentaire = _commentaireController.text.trim();
        _isEditingComment = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Commentaire sauvegardé')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: ${e.toString()}')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _ajouterAuPanier(RecetteViewModel viewModel) {
    try {
     
      viewModel.ajouterAuPanier(recette.ingredients);

      // Affichage d'une confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ingrédients ajoutés au panier'),
          action: SnackBarAction(
            label: 'Voir le panier',
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ajout au panier: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
