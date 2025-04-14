import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_colors.dart';
import 'recette_viewmodel.dart';
import '../../../../data/models/recette_model.dart';
import '../../../../data/models/category_model.dart';

class AddRecetteView extends StatefulWidget {
  const AddRecetteView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddRecetteViewState createState() => _AddRecetteViewState();
}

class _AddRecetteViewState extends State<AddRecetteView> {
  final _formKey = GlobalKey<FormState>();
  final nomController = TextEditingController();
  final categorieController = TextEditingController();
  final descriptionController = TextEditingController();
  final heuresController = TextEditingController();

  final List<Map<String, TextEditingController>> ingredientsControllers = [];
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    addIngredientField();
  }

  void addIngredientField() {
    ingredientsControllers.add({
      'nom': TextEditingController(),
      'quantite': TextEditingController(),
      'prix': TextEditingController(),
    });
    setState(() {});
  }

  void removeIngredientField(int index) {
    if (ingredientsControllers.length > 1) {
      ingredientsControllers.removeAt(index);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Créer une nouvelle recette',
          style: AppTextStyle.headline.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Informations de base
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Informations de base',
                        style: AppTextStyle.subtitle.copyWith(
                          fontSize: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nomController,
                        decoration: InputDecoration(
                          labelText: 'Nom de la recette',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.restaurant_menu),
                        ),
                        style: AppTextStyle.body,
                        validator:
                            (value) => value!.isEmpty ? 'Champ requis' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Catégorie',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items:
                            RecipeCategories.all.map((category) {
                              return DropdownMenuItem<String>(
                                value: category.key,
                                child: Text(
                                  category.title,
                                  style: AppTextStyle.body,
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                        validator:
                            (value) =>
                                value == null
                                    ? 'Veuillez sélectionner une catégorie'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        style: AppTextStyle.body,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: heuresController,
                        decoration: InputDecoration(
                          labelText: 'Temps de préparation (heures)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.timer),
                        ),
                        keyboardType: TextInputType.number,
                        style: AppTextStyle.body,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Section Ingrédients
              Text(
                "Ingrédients",
                style: AppTextStyle.subtitle.copyWith(
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(ingredientsControllers.length, (index) {
                final ctrl = ingredientsControllers[index];
                return Dismissible(
                  key: Key('ingredient-$index'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red.withAlpha(40),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                  onDismissed: (_) => removeIngredientField(index),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'Ingrédient ${index + 1}',
                                style: AppTextStyle.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              if (ingredientsControllers.length > 1)
                                IconButton(
                                  icon: Icon(Icons.close, size: 20),
                                  onPressed: () => removeIngredientField(index),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: ctrl['nom'],
                            decoration: InputDecoration(
                              labelText: 'Nom',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                            style: AppTextStyle.body,
                            validator:
                                (value) =>
                                    value!.isEmpty ? 'Champ requis' : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: ctrl['quantite'],
                                  decoration: InputDecoration(
                                    labelText: 'Quantité (kg)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: AppTextStyle.body,
                                  validator:
                                      (value) =>
                                          value!.isEmpty
                                              ? 'Champ requis'
                                              : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: ctrl['prix'],
                                  decoration: InputDecoration(
                                    labelText: 'Prix unitaire (Ar)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: AppTextStyle.body,
                                  validator:
                                      (value) =>
                                          value!.isEmpty
                                              ? 'Champ requis'
                                              : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton.icon(
                  onPressed: addIngredientField,
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: const Text("Ajouter un ingrédient"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bouton Enregistrer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final recette = Recette(
                        nomRecette: nomController.text,
                        categorie: selectedCategory ?? '',
                        description: descriptionController.text,
                        heuresDePreparation: heuresController.text,
                        commentaire: '',
                        ingredients:
                            ingredientsControllers.map((ctrl) {
                              return Ingredient(
                                nom: ctrl['nom']!.text,
                                quantite:
                                    double.tryParse(ctrl['quantite']!.text) ??
                                    0,
                                prixUnitaire:
                                    double.tryParse(ctrl['prix']!.text) ?? 0,
                              );
                            }).toList(),
                      );

                      context.read<RecetteViewModel>().ajouterRecette(recette);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    "Enregistrer la recette",
                    style: AppTextStyle.button.copyWith(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nomController.dispose();
    categorieController.dispose();
    descriptionController.dispose();
    heuresController.dispose();
    for (var ctrl in ingredientsControllers) {
      ctrl['nom']?.dispose();
      ctrl['quantite']?.dispose();
      ctrl['prix']?.dispose();
    }
    super.dispose();
  }
}
