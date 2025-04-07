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
            imageUrl: 'https://i.blogs.es/886311/flexiones/450_1000.webp',
          ),
          ExerciseCard(
            title: 'Sentadillas',
            description: 'Las sentadillas son perfectas para trabajar las piernas y los glúteos. Realiza 3 series de 15 repeticiones.',
            imageUrl: 'https://media.istockphoto.com/id/1135331615/es/vector/gu%C3%ADa-de-ejercicios-de-mujer-haciendo-sentina-de-aire-en-2-pasos-en-la-vista-lateral-para.jpg?s=612x612&w=0&k=20&c=csc4EoKPDBBCeH3w36NEgbwCGOT7WAFnMWmoEPL5Wfg=',
          ),
          ExerciseCard(
            title: 'Abdominales',
            description: 'Los abdominales ayudan a fortalecer el núcleo. Realiza 3 series de 20 repeticiones.',
            imageUrl: 'https://www.shutterstock.com/image-vector/woman-doing-modified-crunches-abdominals-600nw-2290766949.jpg',
          ),
          ExerciseCard(
            title: 'Plancha',
            description: 'La plancha es un ejercicio isométrico que fortalece el núcleo y los músculos estabilizadores. Mantén la posición durante 30 segundos, 3 series.',
            imageUrl: 'https://www.lorangebleue.fr/wp-content/uploads/2022/12/hombre-haciendo-plancha-abdominal.webp',
          ),
        ],
      ),
    );
  }
}
