import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:feast_fit/widgets/widgets.dart'; // Asegúrate de tener esto

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CustomAppBar2(title: 'Recetas'),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('recipes')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

              final recipes = snapshot.data!.docs;

              return ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index].data() as Map<String, dynamic>;
                  final recipeId = recipes[index].id;
                  final isLiked = (recipe['likes'] ?? []).contains(user?.uid);
                  final isMine = recipe['authorId'] == user?.uid;

                  return Card(
                    margin: const EdgeInsets.all(10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe['title'] ?? 'Sin título',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            recipe['authorEmail'] ?? 'Anónimo',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      subtitle: Text(recipe['description'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(width: 4),
                          Text("${(recipe['likes'] ?? []).length}"),
                          const SizedBox(width: 8),
                          isMine
                              ? IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmDelete(recipeId),
                                )
                              : IconButton(
                                  icon: Icon(
                                    isLiked ? Icons.favorite : Icons.favorite_border,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => _toggleLike(recipeId, isLiked),
                                ),
                        ],
                      ),
                      onTap: () => _showRecipeDetails(recipe),
                    ),
                  );
                },
              );
            },
          ),
        ),
        FloatingActionButton(
          backgroundColor: Colors.brown,
          child: const Icon(Icons.add),
          onPressed: _showAddRecipeDialog,
        ),
      ],
    );
  }

  void _toggleLike(String recipeId, bool isLiked) async {
    final ref = FirebaseFirestore.instance.collection('recipes').doc(recipeId);
    if (isLiked) {
      await ref.update({
        'likes': FieldValue.arrayRemove([user?.uid])
      });
    } else {
      await ref.update({
        'likes': FieldValue.arrayUnion([user?.uid])
      });
    }
  }

  void _confirmDelete(String recipeId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar receta'),
        content: const Text('¿Estás seguro de que deseas eliminar esta receta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('recipes').doc(recipeId).delete();
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showRecipeDetails(Map<String, dynamic> recipe) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(recipe['title']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Descripción: ${recipe['description']}"),
              const SizedBox(height: 10),
              Text("Ingredientes:\n${recipe['ingredients']}"),
              const SizedBox(height: 10),
              Text("Instrucciones:\n${recipe['instructions']}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          )
        ],
      ),
    );
  }

  void _showAddRecipeDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final ingredientsController = TextEditingController();
    final instructionsController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Agregar Receta"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Título')),
              TextField(controller: descController, decoration: const InputDecoration(labelText: 'Descripción')),
              TextField(controller: ingredientsController, decoration: const InputDecoration(labelText: 'Ingredientes')),
              TextField(controller: instructionsController, decoration: const InputDecoration(labelText: 'Instrucciones')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('recipes').add({
                'title': titleController.text,
                'description': descController.text,
                'ingredients': ingredientsController.text,
                'instructions': instructionsController.text,
                'authorId': user?.uid,
                'authorEmail': user?.email,
                'likes': [],
                'timestamp': FieldValue.serverTimestamp(),
              });
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }
}
