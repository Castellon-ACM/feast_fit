import 'package:feast_fit/screens/admin/food_screen_admin.dart';
import 'package:feast_fit/screens/screens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feast_fit/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  Future<bool> _fetchAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    /**
      En el caso de que no exista el campo admin (porque solo se lo he puesto a las cuentas admin)
      devolvera false.
    */

    final data = doc.data();
    final bool isAdmin =
        data != null && data.containsKey('isAdmin') ? data['isAdmin'] : false;

    print("isAdmin: $isAdmin"); // Debugging en consola y to el tema

    return isAdmin;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _fetchAdminStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar datos"));
          }

          bool isAdmin = snapshot.data ?? false;

          return DefaultTabController(
            length: isAdmin ? 2 : 4,
            child: Scaffold(
              body: BackgroundContainer(
                child: TabBarView(
                  children: isAdmin
                      ? [
                          const HomeScreenAdmin(),
                          const FoodScreenAdmin(),
                        ]
                      : [
                          const HomeScreen(),
                          const FoodScreen(),
                          ChartScreen(),
                          const ExerciseScreen(),
                        ],
                ),
              ),
              bottomNavigationBar: TabBar(
                tabs: isAdmin
                    ? [
                        const Tab(icon: Icon(Icons.home), text: 'Inicio'),
                        const Tab(icon: Icon(Icons.fastfood), text: 'Dieta'),
                      ]
                    : [
                        const Tab(icon: Icon(Icons.home), text: 'Inicio'),
                        const Tab(icon: Icon(Icons.fastfood), text: 'Dieta'),
                        const Tab(icon: Icon(Icons.book), text: 'Recetas'),
                        const Tab(icon: Icon(Icons.fitness_center), text: 'Ejercicios'),
                      ],
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.label,
              ),
            ),
          );
        });
  }
}
