import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodScreenAdmin extends StatefulWidget {
  const FoodScreenAdmin({super.key});

  @override
  _FoodScreenAdminState createState() => _FoodScreenAdminState();
}

class _FoodScreenAdminState extends State<FoodScreenAdmin> {
  String? selectedUserId;
  List<String> daysOfWeek = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String defaultFoodImage = 'assets/logo.png';

  @override
  void initState() {
    super.initState();
    daysOfWeek = getDaysOfWeek();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> getDaysOfWeek() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final day = now.add(Duration(days: index));
      return "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    });
  }

  void addRecipeToUser(String day, String mealType, String recipeId) async {
    if (selectedUserId != null) {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(selectedUserId);

      await userRef.set({
        "meals": {
          day: {
            mealType: FieldValue.arrayUnion([recipeId])
          }
        }
      }, SetOptions(merge: true));
    }
  }

  Future<void> removeRecipeFromUser(String day, String mealType, String recipeId) async {
    if (selectedUserId != null) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(selectedUserId);

      // Eliminar la receta del array
      await userRef.update({
        'meals.$day.$mealType': FieldValue.arrayRemove([recipeId])
      });

      // Obtener el documento actualizado
      final userDoc = await userRef.get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      final meals = userData?['meals'] ?? {};
      final dayMeals = meals[day] ?? {};
      final mealRecipes = dayMeals[mealType] ?? [];

      // Verificar si el array está vacío y eliminar el campo si es necesario
      if (mealRecipes.isEmpty) {
        await userRef.update({
          'meals.$day.$mealType': FieldValue.delete()
        });
      }
    }
  }

  void showRecipeSelectionDialog(String day) {
    String selectedMealType = "Desayuno";
    final TextEditingController _searchController = TextEditingController();
    String _searchQuery = "";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Añadir receta"),
            content: SingleChildScrollView(
              child: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: selectedMealType,
                      onChanged: (value) {
                        setState(() {
                          selectedMealType = value!;
                        });
                      },
                      items: ["Desayuno", "Almuerzo", "Snack", "Cena"]
                          .map((type) =>
                              DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                    ),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar recetas por nombre',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 300,
                      ),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('recipes')
                            .where('public', isEqualTo: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final recipes = snapshot.data!.docs.where((doc) {
                            final recipe = doc.data() as Map<String, dynamic>;
                            final title =
                                recipe['title']?.toString().toLowerCase() ?? '';
                            return title.contains(_searchQuery);
                          }).toList();

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: recipes.length,
                            itemBuilder: (context, index) {
                              final recipeData =
                                  recipes[index].data() as Map<String, dynamic>;
                              final recipeId = recipes[index].id;
                              final title = recipeData['title'] ?? 'Sin título';
                              final description = recipeData['description'] ??
                                  'Sin descripción';
                              final imageUrl =
                                  recipeData['imageUrl'] ?? defaultFoodImage;

                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        defaultFoodImage,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                                title: Text(title),
                                subtitle: Text(description),
                                onTap: () {
                                  addRecipeToUser(
                                      day, selectedMealType, recipeId);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar usuario por correo',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('isAdmin', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs.where((doc) {
                  final userData = doc.data() as Map<String, dynamic>;
                  final email =
                      (userData['email'] ?? '').toString().toLowerCase();
                  return _searchQuery.isEmpty || email.contains(_searchQuery);
                }).toList();

                if (users.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron usuarios con ese correo'),
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final userData =
                                users[index].data() as Map<String, dynamic>;
                            final userId = users[index].id;
                            final name = userData['name'] ?? 'Sin nombre';
                            final email = userData['email'] ?? 'Sin correo';

                            return ListTile(
                              title: Text(name),
                              subtitle: Text(email),
                              selected: selectedUserId == userId,
                              selectedTileColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade800
                                  : Colors.blue.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              onTap: () {
                                setState(() {
                                  selectedUserId = userId;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: selectedUserId != null
                          ? _buildFoodPlanView()
                          : const Center(
                              child: Text(
                                'Selecciona un usuario para ver su plan alimenticio',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodPlanView() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(selectedUserId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                );
              }

              final userData = snapshot.data!.data() as Map<String, dynamic>?;
              final name = userData?['name'] ?? 'Usuario';
              final email = userData?['email'] ?? 'Sin correo';

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    if (userData?['weight'] != null &&
                        userData?['height'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Peso: ${userData!['weight']} kg | Altura: ${userData['height']} cm',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    const Divider(height: 24),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: daysOfWeek.length,
              itemBuilder: (context, index) {
                final day = daysOfWeek[index];
                final dateComponents = day.split('-');
                final formattedDay =
                    '${dateComponents[2]}/${dateComponents[1]}/${dateComponents[0]}';

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      formattedDay,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(selectedUserId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final userData =
                              snapshot.data!.data() as Map<String, dynamic>?;
                          final meals = userData?['meals'] ?? {};

                          return Column(
                            children: [
                              for (String mealType in [
                                "Desayuno",
                                "Almuerzo",
                                "Snack",
                                "Cena"
                              ])
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16, top: 8),
                                      child: Text(
                                        mealType.toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (meals[day] != null &&
                                        meals[day][mealType] != null)
                                      for (String recipeId in List<String>.from(
                                          meals[day][mealType]))
                                        StreamBuilder<DocumentSnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('recipes')
                                              .doc(recipeId)
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }

                                            final recipeData =
                                                snapshot.data!.data()
                                                    as Map<String, dynamic>?;
                                            final title =
                                                recipeData?['title'] ??
                                                    'Sin título';

                                            return ListTile(
                                              leading:
                                                  const Icon(Icons.restaurant),
                                              title: Text(title),
                                              trailing: IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () async {
                                                  await removeRecipeFromUser(
                                                      day, mealType, recipeId);
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                  ],
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      showRecipeSelectionDialog(day),
                                  icon: const Icon(Icons.add),
                                  label: const Text("Añadir Receta"),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
