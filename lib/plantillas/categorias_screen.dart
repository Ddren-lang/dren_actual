import 'package:flutter/material.dart';

class CategoriasScreen extends StatelessWidget {
  final List<String> categorias;
  final String selectedCategoria;
  final Function(String) onCategoriaSelected;

  const CategoriasScreen({
    Key? key,
    required this.categorias,
    required this.selectedCategoria,
    required this.onCategoriaSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        backgroundColor: const Color(0xFFC17C9C),
      ),
      body: ListView.builder(
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          final isSelected = categoria == selectedCategoria;
          return ListTile(
            title: Text(categoria),
            trailing: isSelected
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              onCategoriaSelected(categoria);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
