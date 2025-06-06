import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:feast_fit/widgets/widgets.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen>
    with SingleTickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;
  late TabController _tabController;
  bool _showFavoritesOnly = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _filterByAuthorId;
  String? _filterByAuthorEmail;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _clearAuthorFilter() {
    setState(() {
      _filterByAuthorId = null;
      _filterByAuthorEmail = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CustomAppBar2(title: 'Recetas'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar recetas...',
                prefixIcon: const Icon(Icons.search, color: Colors.brown),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.brown),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),
        if (_filterByAuthorEmail != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Chip(
                  label: Text('Recetas de: $_filterByAuthorEmail'),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: _clearAuthorFilter,
                  backgroundColor: Colors.brown.shade100,
                ),
              ],
            ),
          ),
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
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRecipesList(false),
              _buildRecipesList(true),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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

        final filteredRecipes = allRecipes.where((doc) {
          final recipe = doc.data() as Map<String, dynamic>;

          final bool visibilityMatch = recipe['public'] == true || recipe['authorId'] == user?.uid;
          final bool authorMatch = showOnlyMine ? recipe['authorId'] == user?.uid : true;
          final bool favoriteMatch = _showFavoritesOnly ? (recipe['likes'] ?? []).contains(user?.uid) : true;
          final bool specificAuthorMatch = _filterByAuthorId != null ? recipe['authorId'] == _filterByAuthorId : true;
          final bool searchMatch = _searchQuery.isEmpty ? true : (recipe['title']?.toString().toLowerCase().contains(_searchQuery) ?? false) || (recipe['description']?.toString().toLowerCase().contains(_searchQuery) ?? false) || (recipe['ingredients']?.toString().toLowerCase().contains(_searchQuery) ?? false);

          return visibilityMatch && authorMatch && favoriteMatch && specificAuthorMatch && searchMatch;
        }).toList();

        if (filteredRecipes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _searchQuery.isNotEmpty ? 'No se encontraron recetas con "$_searchQuery"' : _filterByAuthorEmail != null ? 'No hay recetas de $_filterByAuthorEmail' : _showFavoritesOnly ? 'No tienes recetas favoritas' : (showOnlyMine ? 'No has creado recetas aún' : 'No hay recetas disponibles'),
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                if (_searchQuery.isNotEmpty || _filterByAuthorEmail != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _clearAuthorFilter();
                      });
                    },
                    child: const Text('Limpiar filtros'),
                  ),
              ],
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
            final imageUrl = recipe['imageUrl'] as String?;

            return Card(
              margin: const EdgeInsets.all(10),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  if (imageUrl != null && imageUrl.isNotEmpty)
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe['title'] ?? 'Sin título',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _filterByAuthorId = recipe['authorId'];
                              _filterByAuthorEmail = recipe['authorEmail'];
                              if (_tabController.index == 1) {
                                _tabController.animateTo(0);
                              }
                            });
                          },
                          child: Text(
                            recipe['authorEmail'] ?? 'Anónimo',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(recipe['description'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 4),
                        Text("${(recipe['likes'] ?? []).length}"),
                        const SizedBox(width: 8),
                        isMine
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.orange),
                                    onPressed: () => _showEditRecipeDialog(recipeId, recipe),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _confirmDelete(recipeId),
                                  ),
                                ],
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
                ],
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
      await ref.update({'likes': FieldValue.arrayRemove([user?.uid])});
    } else {
      await ref.update({'likes': FieldValue.arrayUnion([user?.uid])});
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
              if (recipe['imageUrl'] != null && recipe['imageUrl'].isNotEmpty)
                Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      recipe['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
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

  void _showEditRecipeDialog(String recipeId, Map<String, dynamic> recipe) {
    final titleController = TextEditingController(text: recipe['title']);
    final descController = TextEditingController(text: recipe['description']);
    final ingredientsController = TextEditingController(text: recipe['ingredients']);
    final instructionsController = TextEditingController(text: recipe['instructions']);
    final imageUrlController = TextEditingController(text: recipe['imageUrl']);

    bool isPublic = recipe['public'] ?? true;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Editar Receta"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: ingredientsController,
                  decoration: const InputDecoration(labelText: 'Ingredientes'),
                ),
                TextField(
                  controller: instructionsController,
                  decoration: const InputDecoration(labelText: 'Instrucciones'),
                ),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(labelText: 'URL de la Imagen'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("¿Pública?"),
                    Switch(
                      value: isPublic,
                      onChanged: (value) {
                        setState(() {
                          isPublic = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );

                await FirebaseFirestore.instance.collection('recipes').doc(recipeId).update({
                  'title': titleController.text,
                  'description': descController.text,
                  'ingredients': ingredientsController.text,
                  'instructions': instructionsController.text,
                  'imageUrl': imageUrlController.text,
                  'public': isPublic,
                });

                Navigator.pop(context); // Cerrar loading
                Navigator.pop(context); // Cerrar dialog
              },
              child: const Text("Guardar Cambios"),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRecipeDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final ingredientsController = TextEditingController();
    final instructionsController = TextEditingController();
    final imageUrlController = TextEditingController();

    bool isPublic = true;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Agregar Receta"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: ingredientsController,
                  decoration: const InputDecoration(labelText: 'Ingredientes'),
                ),
                TextField(
                  controller: instructionsController,
                  decoration: const InputDecoration(labelText: 'Instrucciones'),
                ),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(labelText: 'URL de la Imagen'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("¿Pública?"),
                    Switch(
                      value: isPublic,
                      onChanged: (value) {
                        setState(() {
                          isPublic = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );

                final docRef = FirebaseFirestore.instance.collection('recipes').doc();

                await docRef.set({
                  'title': titleController.text,
                  'description': descController.text,
                  'ingredients': ingredientsController.text,
                  'instructions': instructionsController.text,
                  'imageUrl': imageUrlController.text,
                  'authorId': user?.uid,
                  'authorEmail': user?.email,
                  'likes': [],
                  'public': isPublic,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                Navigator.pop(context); // Cerrar loading
                Navigator.pop(context); // Cerrar dialog
              },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }
}
