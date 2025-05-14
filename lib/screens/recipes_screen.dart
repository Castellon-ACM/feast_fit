import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:feast_fit/widgets/widgets.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> with SingleTickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;
  late TabController _tabController;
  bool _showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CustomAppBar2(title: 'Recetas'),
        // Segundo AppBar con pestañas
        Container(
          color: Colors.brown.shade200,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.brown.shade800,
            labelColor: Colors.brown.shade900,
            unselectedLabelColor: Colors.brown.shade600,
            tabs: const [
              Tab(text: 'Todas las recetas'),
              Tab(text: 'Mis recetas'),
            ],
            onTap: (index) {
              // Actualizar el estado para forzar reconstrucción
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Pestaña "Todas las recetas"
              _buildRecipesList(false),
              // Pestaña "Mis recetas"
              _buildRecipesList(true),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Botón para filtrar favoritos
              FloatingActionButton(
                heroTag: 'favorites',
                backgroundColor: _showFavoritesOnly ? Colors.red : Colors.grey,
                child: const Icon(Icons.favorite),
                onPressed: () {
                  setState(() {
                    _showFavoritesOnly = !_showFavoritesOnly;
                  });
                },
              ),
              const SizedBox(width: 16),
              // Botón para añadir recetas
              FloatingActionButton(
                heroTag: 'add',
                backgroundColor: Colors.brown,
                child: const Icon(Icons.add),
                onPressed: _showAddRecipeDialog,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecipesList(bool showOnlyMine) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('recipes')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final allRecipes = snapshot.data!.docs;
        
        // Filtrar recetas según los criterios
        final filteredRecipes = allRecipes.where((doc) {
          final recipe = doc.data() as Map<String, dynamic>;
          
          // Filtrar por autor (mis recetas o todas)
          final bool authorMatch = showOnlyMine 
              ? recipe['authorId'] == user?.uid 
              : true;
          
          // Filtrar por favoritos si está activado
          final bool favoriteMatch = _showFavoritesOnly 
              ? (recipe['likes'] ?? []).contains(user?.uid)
              : true;
          
          return authorMatch && favoriteMatch;
        }).toList();

        if (filteredRecipes.isEmpty) {
          return Center(
            child: Text(
              _showFavoritesOnly 
                ? 'No tienes recetas favoritas' 
                : (showOnlyMine ? 'No has creado recetas aún' : 'No hay recetas disponibles'),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredRecipes.length,
          itemBuilder: (context, index) {
            final recipe = filteredRecipes[index].data() as Map<String, dynamic>;
            final recipeId = filteredRecipes[index].id;
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