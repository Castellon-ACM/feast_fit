import 'package:feast_fit/widgets/widgets.dart';
import 'package:flutter/material.dart';
// Asegúrate de importar SettingsScreen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar2(title: 'Inicio'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenido a FeastFit',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Explora recetas saludables y personaliza tu plan de alimentación.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  buildFeaturedRecipe(context),
                  const SizedBox(height: 20),
                  buildRecommendedRecipes(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFeaturedRecipe(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage('assets/logo.png'),
          fit: BoxFit.cover,
        ),
      ),
      height: 200,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: const Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            'Receta Destacada: Ensalada Cesar',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget buildRecommendedRecipes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recomendaciones',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              buildRecipeCard('Smoothie de Fresa', 'assets/logo.png'),
              buildRecipeCard('Avena con Frutas', 'assets/logo.png'),
              buildRecipeCard('Tostadas con Aguacate', 'assets/logo.png'),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildRecipeCard(String title, String imagePath) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Image.asset(
              imagePath,
              width: 120,
              height: 150,
              fit: BoxFit.cover,
            ),
            Container(
              width: 120,
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
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
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
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
