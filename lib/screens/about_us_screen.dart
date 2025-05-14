import 'package:feast_fit/widgets/widgets.dart';
import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: const CustomAppBar3(
        title: 'Información',
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Center(
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.restaurant_menu,
                        size: 60,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'FeastFit',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tu compañero en nutrición personalizada',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Sobre Nosotros',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'En FeastFit, estamos comprometidos a transformar la manera en que las personas se relacionan con su alimentación. Creemos que una dieta equilibrada no significa restricciones, sino encontrar el balance perfecto entre nutrición y placer.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 12),
              const Text(
                'Nuestra aplicación nació de la necesidad de simplificar la planificación de comidas saludables, haciendo que sea accesible para todos, independientemente de sus objetivos nutricionales o restricciones dietéticas.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Nuestra Misión',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Empoderar a las personas para que tomen el control de su nutrición a través de planes de alimentación personalizados, recetas deliciosas y seguimiento intuitivo, todo respaldado por la ciencia nutricional más actualizada.',
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Nuestros Creadores',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  Column(
                    children: [
                      const CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage('assets/cesar.jpg'),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Alejandro Castellón Martín',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Desarrollador & Co-fundador',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  

                  Column(
                    children: [
                      const CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage('assets/cesar.jpg'),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Iván Pérez Ossintsev',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Desarrollador & Co-fundador',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Nuestra Historia',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'FeastFit comenzó en 2023 como un proyecto personal entre dos amigos que compartían la misma pasión: combinar la tecnología con la nutrición para mejorar la vida de las personas.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 12),
              const Text(
                'Lo que comenzó como una simple herramienta para planificar comidas se ha convertido en una plataforma completa que ayuda a miles de usuarios a alcanzar sus objetivos de salud a través de planes personalizados, recetas deliciosas y seguimiento nutricional.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Contáctanos',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(
                  Icons.email_outlined,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('info@feastfit.com'),
              ),
              ListTile(
                leading: Icon(
                  Icons.phone_outlined,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('+34 612 345 678'),
              ),
              ListTile(
                leading: Icon(
                  Icons.language_outlined,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('www.feastfit.com'),
              ),
              
              const SizedBox(height: 40),
              Center(
                child: Text(
                  '© ${DateTime.now().year} FeastFit - Todos los derechos reservados',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}