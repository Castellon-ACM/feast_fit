import 'package:feast_fit/screens/user/food_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:feast_fit/widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const CustomAppBar2(
          title: 'Bienvenido a FeastFit',
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  'Explora recetas saludables y personaliza tu plan de alimentación.',
                  style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _buildFeaturedRecipe(context),
                      const SizedBox(height: 20),
                      _buildRecommendedRecipes(context),
                      const SizedBox(height: 20),
                      _buildDailyPlan(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedRecipe(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage('assets/cesar.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      height: 200,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              theme.primaryColorDark.withOpacity(0.6),
              Colors.transparent
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            'Receta Destacada: Ensalada Cesar',
            style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedRecipes(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recomendaciones',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('recipes')
                .where('public',
                    isEqualTo:
                        true) 
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Text('Error al cargar recomendaciones');
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Text('No hay recetas públicas disponibles');
              }

              docs.shuffle();
              final randomRecipes = docs.take(5).toList();

              return ListView(
                scrollDirection: Axis.horizontal,
                children: randomRecipes.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = data['title'] ?? 'Sin título';
                  final imageUrl = data['imageUrl'] ?? 'assets/logo.png';
                  final description = data['description'] ?? 'Sin descripción';
                  final calories = data['calories'] ?? '400 calorías';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FoodDetailScreen(
                            foodName: title,
                            imageUrl: imageUrl,
                            description: description,
                            calories: calories,
                            mealType: 'Recomendación',
                          ),
                        ),
                      );
                    },
                    child: _buildRecipeCard(context, title, imageUrl),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyPlan(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Text('Error al cargar el plan del día');
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Text('No se encontró información del plan del día');
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final meals = userData['meals'] as Map<String, dynamic>? ?? {};
        final dayMeals = meals[formattedDate] as Map<String, dynamic>? ?? {};

        if (dayMeals.isEmpty) {
          return const Center(
            child: Text(
              'NO HAY COMIDA HOY',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 85, 54, 29),
              ),
            ),
          );
        }

        final mealTypes = ["Desayuno", "Almuerzo", "Snack", "Cena"];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan del Día',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: mealTypes.map<Widget>((mealType) {
                  final foodList = dayMeals[mealType] as List<dynamic>? ?? [];

                  if (foodList.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('recipes')
                        .where(FieldPath.documentId, whereIn: foodList)
                        .get(),
                    builder: (context, recipeSnapshot) {
                      if (recipeSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (recipeSnapshot.hasError) {
                        return const Text('Error al cargar las recetas');
                      }

                      final recipes = recipeSnapshot.data?.docs ?? [];

                      if (recipes.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Row(
                        children: recipes.map<Widget>((recipeDoc) {
                          final recipeData =
                              recipeDoc.data() as Map<String, dynamic>;
                          final title = recipeData['title'] ?? 'Sin título';
                          final imageUrl =
                              recipeData['imageUrl'] ?? 'assets/logo.png';
                          final description =
                              recipeData['description'] ?? 'Sin descripción';
                          final calories =
                              recipeData['calories'] ?? '400 calorías';

                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FoodDetailScreen(
                                      foodName: title,
                                      imageUrl: imageUrl,
                                      description: description,
                                      calories: calories,
                                      mealType: mealType,
                                    ),
                                  ),
                                );
                              },
                              child: _buildRecipeCard(context, title, imageUrl),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecipeCard(
      BuildContext context, String title, String? imagePath) {
    final theme = Theme.of(context);
    final isNetworkImage = imagePath != null && imagePath.startsWith('http');

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            isNetworkImage
                ? Image.network(
                    imagePath!,
                    width: 130,
                    height: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/logo.png',
                        width: 130,
                        height: 130,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    (imagePath != null &&
                            imagePath.isNotEmpty &&
                            !imagePath
                                .contains('asdda')) // previene paths falsos
                        ? imagePath
                        : 'assets/logo.png',
                    width: 130,
                    height: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/logo.png',
                        width: 130,
                        height: 130,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColorDark.withOpacity(0.6),
                    Colors.transparent
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
