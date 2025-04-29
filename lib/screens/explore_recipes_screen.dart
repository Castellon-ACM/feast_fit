import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:feast_fit/widgets/widgets.dart';

class ExploreRecipesScreen extends StatefulWidget {
  const ExploreRecipesScreen({super.key});

  @override
  _ExploreRecipesScreenState createState() => _ExploreRecipesScreenState();
}

class _ExploreRecipesScreenState extends State<ExploreRecipesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  List<String> _userFavorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserFavorites();
  }

  Future<void> _fetchUserFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists && userDoc.data()!.containsKey('favorites')) {
          setState(() {
            _userFavorites = List<String>.from(userDoc.data()!['favorites'] ?? []);
          });
        }
      }
    } catch (e) {
      print('Error fetching favorites: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(String recipeId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      if (_userFavorites.contains(recipeId)) {
        // Remove from favorites
        setState(() {
          _userFavorites.remove(recipeId);
        });
        await _firestore.collection('users').doc(userId).update({
          'favorites': FieldValue.arrayRemove([recipeId])
        });
      } else {
        // Add to favorites
        setState(() {
          _userFavorites.add(recipeId);
        });
        await _firestore.collection('users').doc(userId).update({
          'favorites': FieldValue.arrayUnion([recipeId])
        });
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      // Revert the state change if there was an error
      await _fetchUserFavorites();
    }
  }

  Future<void> _likeRecipe(String recipeId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      // Check if user already liked this recipe
      final likeDoc = await _firestore
          .collection('recipes')
          .doc(recipeId)
          .collection('likes')
          .doc(userId)
          .get();

      if (likeDoc.exists) {
        // Unlike the recipe
        await _firestore
            .collection('recipes')
            .doc(recipeId)
            .collection('likes')
            .doc(userId)
            .delete();

        await _firestore.collection('recipes').doc(recipeId).update({
          'likesCount': FieldValue.increment(-1)
        });
      } else {
        // Like the recipe
        await _firestore
            .collection('recipes')
            .doc(recipeId)
            .collection('likes')
            .doc(userId)
            .set({
          'timestamp': FieldValue.serverTimestamp(),
        });

        await _firestore.collection('recipes').doc(recipeId).update({
          'likesCount': FieldValue.increment(1)
        });
      }
    } catch (e) {
      print('Error liking recipe: $e');
    }
  }

  Future<bool> _checkIfLiked(String recipeId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    try {
      final likeDoc = await _firestore
          .collection('recipes')
          .doc(recipeId)
          .collection('likes')
          .doc(userId)
          .get();
      return likeDoc.exists;
    } catch (e) {
      print('Error checking if liked: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Explorar Recetas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: AnimatedGradientBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar recetas...',
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white24,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  hintStyle: const TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<QuerySnapshot>(
                      stream: _firestore.collection('recipes').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final recipes = snapshot.data!.docs;
                        
                        // Filter recipes based on search
                        final filteredRecipes = _searchController.text.isEmpty
                            ? recipes
                            : recipes.where((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final title = data['title'].toString().toLowerCase();
                                final search = _searchController.text.toLowerCase();
                                return title.contains(search);
                              }).toList();

                        if (filteredRecipes.isEmpty) {
                          return const Center(
                            child: Text(
                              'No se encontraron recetas',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: filteredRecipes.length,
                          itemBuilder: (context, index) {
                            final doc = filteredRecipes[index];
                            final data = doc.data() as Map<String, dynamic>;
                            final recipeId = doc.id;
                            final title = data['title'] ?? 'Sin título';
                            final description = data['description'] ?? 'Sin descripción';
                            final imageUrl = data['imageUrl'] ?? '';
                            final likesCount = data['likesCount'] ?? 0;
                            final authorId = data['authorId'] ?? '';
                            final authorName = data['authorName'] ?? 'Anónimo';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: Colors.white.withOpacity(0.9),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                    ),
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(
                                            imageUrl,
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                height: 200,
                                                color: Colors.grey[300],
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.error_outline,
                                                    size: 40,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            height: 200,
                                            color: Colors.grey[300],
                                            child: const Center(
                                              child: Icon(
                                                Icons.restaurant,
                                                size: 60,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                title,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            FutureBuilder<bool>(
                                              future: _checkIfLiked(recipeId),
                                              builder: (context, snapshot) {
                                                final isLiked = snapshot.data ?? false;
                                                return IconButton(
                                                  icon: Icon(
                                                    isLiked
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    color: isLiked ? Colors.red : null,
                                                  ),
                                                  onPressed: () => _likeRecipe(recipeId),
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                _userFavorites.contains(recipeId)
                                                    ? Icons.bookmark
                                                    : Icons.bookmark_border,
                                                color: _userFavorites.contains(recipeId)
                                                    ? Colors.amber
                                                    : null,
                                              ),
                                              onPressed: () => _toggleFavorite(recipeId),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          description,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Por: $authorName',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.favorite,
                                                  size: 16,
                                                  color: Colors.red,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '$likesCount',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      // Navegación a la pantalla de detalle de receta
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => RecipeDetailScreen(recipeId: recipeId),
                                      //   ),
                                      // );
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.green[700],
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(15),
                                          bottomRight: Radius.circular(15),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Ver Detalles',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}