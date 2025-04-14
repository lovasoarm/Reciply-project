import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reciply/data/models/recette_model.dart';
import 'package:reciply/presentation/pages/home/homeview.dart';
import 'package:reciply/presentation/pages/home/profile/profile.dart';
import 'package:reciply/presentation/pages/home/recette/addrecette_view.dart';
import 'package:reciply/presentation/pages/home/recette/details.dart';
import 'package:reciply/presentation/pages/home/recette/recette_viewmodel.dart';
import 'package:reciply/core/services/firebase/services.dart';
import '../presentation/pages/splash-screen/splash.dart';
import '../presentation/pages/auth/login_view.dart';
import '../presentation/pages/auth/register_view.dart';
import '../presentation/pages/welcome/welcome.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const SplashScreen(),
  '/login': (context) => LoginView(),
  '/signup': (context) => RegisterView(),
  '/welcome': (context) => BienvenueView(),
  '/home': (context) => HomeView(),
  '/addrecetteview': (context) => AddRecetteView(),
  '/profile':
      (context) => Provider<Services>(
        create: (context) => Services(),
        child: const ProfilePage(),
      ),
  '/recetteDetail': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final recette = args['recette'] as Recette;
    final recetteId = args['recetteId'] as String;

    return ChangeNotifierProvider(
      create: (context) => RecetteViewModel(Services()),
      child: DetailView(recette: recette, recetteId: recetteId),
    );
  },
};
