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
            description:
                'Las flexiones son un ejercicio excelente para fortalecer los brazos, el pecho y los hombros. Realiza 3 series de 10 repeticiones.',
            imageUrl: 'assets/flexiones.png',
            url: 'https://es.wikipedia.org/wiki/Flexi%C3%B3n_de_codos',
          ),
          ExerciseCard(
            title: 'Sentadillas',
            description:
                'Las sentadillas son perfectas para trabajar las piernas y los glúteos. Realiza 3 series de 15 repeticiones.',
            imageUrl: 'assets/sentadillas.png',
            url: 'https://es.wikipedia.org/wiki/Sentadilla',
          ),
          ExerciseCard(
            title: 'Abdominales',
            description:
                'Los abdominales ayudan a fortalecer el núcleo. Realiza 3 series de 20 repeticiones.',
            imageUrl: 'assets/abdominales.png',
            url: 'https://www.mayoclinic.org/es/healthy-lifestyle/fitness/multimedia/abdominal-crunch/vid-20084664',
          ),
          ExerciseCard(
            title: 'Plancha',
            description:
                'La plancha es un ejercicio isométrico que fortalece el núcleo y los músculos estabilizadores. Mantén la posición durante 30 segundos, 3 series.',
            imageUrl: 'assets/plancha.webp',
            url: 'https://www.respirapilates.com/plancha-abdominal-fortalecer-abdomen-y-torso/',
          ),
        ],
      ),
    );
  }
}
