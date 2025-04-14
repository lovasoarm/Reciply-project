import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/recette_model.dart';

class Services {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseFirestore get firestore => _firestore;

  Future<User?> signIn(UserModel user) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> register(UserModel user) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': user.username,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> ajouterRecette(Recette recette) async {
    final user = currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('recettes')
        .add(recette.toMap());
  }

  Future<void> modifierRecette(String recetteId, Recette recette) async {
    final user = currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('recettes')
        .doc(recetteId)
        .set(recette.toMap());
  }

  Future<void> supprimerRecette(String recetteId) async {
    final user = currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('recettes')
        .doc(recetteId)
        .delete();
  }

  Stream<List<MapEntry<String, Recette>>> recettesUtilisateurStream() {
    final user = currentUser;
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

  Future<void> updateRecette(Recette recette) async {
    final recetteRef = FirebaseFirestore.instance
        .collection('recettes')
        .doc(recette.nomRecette);
    await recetteRef.update(recette.toMap());
  }
}
