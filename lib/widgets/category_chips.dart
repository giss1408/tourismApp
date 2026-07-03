// widgets/category_chips.dart
import 'package:flutter/material.dart';

class CategoryChips extends StatefulWidget {
  const CategoryChips({super.key});

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': Icons.all_inclusive, 'color': Colors.blue},
    {'name': 'Beach', 'icon': Icons.beach_access, 'color': Colors.orange},
    {'name': 'Mountain', 'icon': Icons.landscape, 'color': Colors.green},
    {'name': 'City', 'icon': Icons.location_city, 'color': Colors.purple},
    {'name': 'Historical', 'icon': Icons.castle, 'color': Colors.brown},
    {'name': 'Adventure', 'icon': Icons.hiking, 'color': Colors.red},
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
                      color: isSelected ? category['color'] as Color : Colors.grey,
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