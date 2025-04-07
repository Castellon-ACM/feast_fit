import 'package:flutter/material.dart';
import 'package:feast_fit/widgets/exercise_card.dart';

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
            imageUrl: 'https://example.com/pushups.jpg',
          ),
          ExerciseCard(
            title: 'Sentadillas',
            description: 'Las sentadillas son perfectas para trabajar las piernas y los glúteos. Realiza 3 series de 15 repeticiones.',
            imageUrl: 'https://example.com/squats.jpg',
          ),
          ExerciseCard(
            title: 'Abdominales',
            description: 'Los abdominales ayudan a fortalecer el núcleo. Realiza 3 series de 20 repeticiones.',
            imageUrl: 'https://example.com/crunches.jpg',
          ),
          ExerciseCard(
            title: 'Plancha',
            description: 'La plancha es un ejercicio isométrico que fortalece el núcleo y los músculos estabilizadores. Mantén la posición durante 30 segundos, 3 series.',
            imageUrl: 'https://example.com/plank.jpg',
          ),
        ],
      ),
    );
  }
}
