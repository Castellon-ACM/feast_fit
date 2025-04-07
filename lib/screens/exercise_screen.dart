import 'package:flutter/material.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejercicios en Casa'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          ExerciseCard(
            title: 'Flexiones',
            description: 'Las flexiones son un ejercicio excelente para fortalecer los brazos, el pecho y los hombros. Realiza 3 series de 10 repeticiones.',
            imageUrl: 'https://example.com/pushups.jpg', // Reemplaza con la URL de la imagen
          ),
          ExerciseCard(
            title: 'Sentadillas',
            description: 'Las sentadillas son perfectas para trabajar las piernas y los glúteos. Realiza 3 series de 15 repeticiones.',
            imageUrl: 'https://example.com/squats.jpg', // Reemplaza con la URL de la imagen
          ),
          ExerciseCard(
            title: 'Abdominales',
            description: 'Los abdominales ayudan a fortalecer el núcleo. Realiza 3 series de 20 repeticiones.',
            imageUrl: 'https://example.com/crunches.jpg', // Reemplaza con la URL de la imagen
          ),
          ExerciseCard(
            title: 'Plancha',
            description: 'La plancha es un ejercicio isométrico que fortalece el núcleo y los músculos estabilizadores. Mantén la posición durante 30 segundos, 3 series.',
            imageUrl: 'https://example.com/plank.jpg', // Reemplaza con la URL de la imagen
          ),
        ],
      ),
    );
  }
}

class ExerciseCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  const ExerciseCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  description,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
