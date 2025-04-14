import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app.dart';
import 'firebase_options.dart';

import 'core/services/firebase/services.dart';
import 'presentation/pages/auth/register_viewmodel.dart';
import 'presentation/pages/home/recette/recette_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase 
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authService = Services(); // Service d'authentification

  runApp(
    MultiProvider(
      providers: [
    
        Provider<Services>.value(value: authService),

        // ViewModel pour la vue d'enregistrement
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),

        // ViewModel pour la gestion des recettes
        ChangeNotifierProvider(create: (_) => RecetteViewModel(authService)),
      ],
      child: const ReciplyApp(), 
    ),
  );
}
