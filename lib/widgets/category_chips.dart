// widgets/category_chips.dart
import 'package:flutter/material.dart';

class CategoryChips extends StatefulWidget {
  const CategoryChips({super.key});

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> categories = const [
    {'name': 'All', 'icon': Icons.all_inclusive, 'color': Color(0xFF145DA0)},
    {'name': 'Beach', 'icon': Icons.beach_access, 'color': Color(0xFF1A8A84)},
    {'name': 'Mountain', 'icon': Icons.landscape, 'color': Color(0xFF2E7D6B)},
    {'name': 'City', 'icon': Icons.location_city, 'color': Color(0xFF5D6D7E)},
    {'name': 'Historical', 'icon': Icons.castle, 'color': Color(0xFF8A6D3B)},
    {'name': 'Adventure', 'icon': Icons.hiking, 'color': Color(0xFFB35C2E)},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category['name'];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category['name'];
              });
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  // Category Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? category['color'] as Color
                          : (category['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? Border.all(color: category['color'] as Color, width: 2)
                          : null,
                    ),
                    child: Icon(
                      category['icon'] as IconData,
                      color: isSelected ? Colors.white : category['color'] as Color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Category Name
                  Text(
                    category['name'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? category['color'] as Color
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.62),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}