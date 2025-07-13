import 'package:flutter/material.dart';
import 'package:fitbliss/data/models/nutrition_model.dart';

class NutritionDetailScreen extends StatelessWidget {
  final NutritionModel nutrition;

  const NutritionDetailScreen({super.key, required this.nutrition});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'nutrition-image-${nutrition.id}',
                child: Image.network(
                  nutrition.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.food_bank, size: 100),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          nutrition.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Chip(
                        label: Text(
                          nutrition.category.displayName,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    nutrition.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildNutritionInfoRow(),
                  const SizedBox(height: 32),
                  if (nutrition.benefits.isNotEmpty) _buildBenefitsSection(),
                  if (nutrition.preparation.isNotEmpty)
                    _buildPreparationSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionInfoRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNutritionInfoItem(
            icon: Icons.local_fire_department,
            value: '${nutrition.calories} kcal',
            label: 'Calories',
          ),
          _buildNutritionInfoItem(
            icon: Icons.fitness_center,
            value: nutrition.protein,
            label: 'Protein',
          ),
          _buildNutritionInfoItem(
            icon: Icons.energy_savings_leaf,
            value: nutrition.carbs,
            label: 'Carbs',
          ),
          _buildNutritionInfoItem(
            icon: Icons.water_drop,
            value: nutrition.fats,
            label: 'Fats',
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionInfoItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey[700]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Benefits',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...nutrition.benefits.map(
          (benefit) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4.0, right: 8.0),
                  child: Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: Text(
                    benefit,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreparationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Preparation',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...nutrition.preparation.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.pink[100],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
