import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:feast_fit/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isSaving = false;
  bool _dataLoaded = false;
  
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  
  // Cambiamos a String? para el dropdown
  String? _selectedSportActivity;
  
  final List<String> _sportActivityOptions = [
    'Ninguno',
    '1-2 veces por semana',
    '3-4 veces por semana',
    '5 o más veces por semana'
  ];
  
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _fetchUserData().then((data) {
      setState(() {
        _userData = data;
        _loadDataToControllers();
        _dataLoaded = true;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _loadDataToControllers() {
    _nameController.text = _userData['name'] ?? '';
    _emailController.text = _userData['email'] ?? '';
    _weightController.text = _userData['weight'] ?? '';
    _heightController.text = _userData['height'] ?? '';
    
    // Cargar la actividad deportiva seleccionada
    String? savedActivity = _userData['sportActivity'];
    if (savedActivity != null && _sportActivityOptions.contains(savedActivity)) {
      _selectedSportActivity = savedActivity;
    } else {
      _selectedSportActivity = null;
    }
    
    print("Datos cargados en controladores: Nombre=${_nameController.text}, Email=${_emailController.text}, Actividad=$_selectedSportActivity");
  }

  Future<void> _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });
      
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final updatedData = {
            'name': _nameController.text,
            'email': _emailController.text,
            'weight': _weightController.text,
            'height': _heightController.text,
            'sportActivity': _selectedSportActivity ?? '',
          };
          
          print("Guardando datos: $updatedData");
          
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update(updatedData);

          setState(() {
            _userData = updatedData;
            _isEditing = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Perfil actualizado correctamente')),
            );
          }
        }
      } catch (e) {
        print("Error al guardar: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al guardar: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar3(
        title: 'Perfil',
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  _isEditing = false;
                  _loadDataToControllers(); 
                } else {
                  _isEditing = true;
                  _loadDataToControllers();
                }
              });
            },
          ),
        ],
      ),
      body: _dataLoaded 
          ? _buildContent()
          : FutureBuilder(
              future: _fetchUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error al cargar los datos: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                } else if (snapshot.hasData) {
                  if (!_dataLoaded) {
                    _userData = snapshot.data!;
                    _loadDataToControllers();
                    _dataLoaded = true;
                  }
                  return _buildContent();
                } else {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No hay datos disponibles',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }
              },
            ),
      floatingActionButton: _isEditing
          ? FloatingActionButton(
              onPressed: _isSaving ? null : _saveUserData,
              backgroundColor: _isSaving ? Colors.grey : Colors.brown,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save),
            )
          : null,
    );
  }

  Widget _buildContent() {
    return Container(
      color: Colors.brown[50],
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _isEditing
                ? _buildEditableForm()
                : _buildDisplayProfile(),
          ),
        ),
      ),
    );
  }

  Widget _buildDisplayProfile() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Perfil de Usuario',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 104, 79, 74),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildUserInfo('Nombre', _userData['name'] ?? ''),
        _buildUserInfo('Correo', _userData['email'] ?? ''),
        _buildUserInfo('Peso', '${_userData['weight'] ?? 0} kg'),
        _buildUserInfo('Altura', '${_userData['height'] ?? 0} cm'),
        _buildUserInfo('Actividad Deportiva', _userData['sportActivity'] ?? ''),
      ],
    );
  }

  Widget _buildEditableForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Editar Perfil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 104, 79, 74),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _nameController,
            label: 'Nombre',
            validator: (value) => value!.isEmpty ? 'Ingrese su nombre' : null,
          ),
          _buildTextField(
            controller: _emailController,
            label: 'Correo',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value!.isEmpty) return 'Ingrese su correo';
              if (!value.contains('@')) return 'Ingrese un correo válido';
              return null;
            },
          ),
          _buildTextField(
            controller: _weightController,
            label: 'Peso (kg)',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) return 'Ingrese su peso';
              if (double.tryParse(value) == null) return 'Ingrese un número válido';
              return null;
            },
          ),
          _buildTextField(
            controller: _heightController,
            label: 'Altura (cm)',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value!.isEmpty) return 'Ingrese su altura';
              if (double.tryParse(value) == null) return 'Ingrese un número válido';
              return null;
            },
          ),
          _buildSportActivityDropdown(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.brown.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.brown.shade700, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 16),
        cursorColor: Colors.brown,
      ),
    );
  }

  Widget _buildSportActivityDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Actividad Deportiva',
          prefixIcon: Icon(Icons.sports, color: Colors.brown.shade600),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.brown.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.brown.shade700, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        value: _selectedSportActivity,
        items: _sportActivityOptions
            .map((label) => DropdownMenuItem(
                value: label,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 104, 79, 74),
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                )))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedSportActivity = value;
          });
        },
        validator: (value) => value == null || value.isEmpty
            ? 'Por favor selecciona tu actividad deportiva'
            : null,
        dropdownColor: Colors.white,
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.brown.shade600,
        ),
        isExpanded: true,
      ),
    );
  }

  Widget _buildUserInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 104, 79, 74),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value.isNotEmpty ? value : 'No especificado',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const Divider(color: Colors.brown, thickness: 0.5),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    if (_userData.isNotEmpty && _dataLoaded) {
      return _userData;
    }
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        print("Datos obtenidos de Firestore: ${doc.data()}");
        return doc.data()!;
      }
    }
    return {};
  }
}