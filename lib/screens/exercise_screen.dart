import 'package:flutter/material.dart';
import 'package:feast_fit/widgets/exercise_card.dart';
import 'package:feast_fit/widgets/widgets.dart'; 
class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar2(title: 'Ejercicios en Casa'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: const [
                  ExerciseCard(
                    title: 'Flexiones',
                    description:
                        'Las flexiones son un ejercicio excelente para fortalecer los brazos, el pecho y los hombros.',
                    imageUrl: 'assets/flexiones.png',
                    url: 'https://feastfit.kesug.com/flexiones/',
                  ),
                  ExerciseCard(
                    title: 'Sentadillas',
                    description:
                        'Las sentadillas son perfectas para trabajar las piernas y los glúteos.',
                    imageUrl: 'assets/sentadillas.png',
                    url: 'https://feastfit.kesug.com/sentadillas/',
                  ),
                  ExerciseCard(
                    title: 'Abdominales',
                    description:
                        'Los abdominales ayudan a fortalecer el núcleo.',
                    imageUrl: 'assets/abdominales.png',
                    url: 'https://feastfit.kesug.com/abdominales/',
                  ),
                  ExerciseCard(
                    title: 'Plancha',
                    description:
                        'La plancha es un ejercicio isométrico que fortalece el núcleo y los músculos estabilizadores.',
                    imageUrl: 'assets/plancha.webp',
                    url: 'https://feastfit.kesug.com/plancha/',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}