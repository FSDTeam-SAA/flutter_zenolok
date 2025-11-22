import 'package:flutter/material.dart';

class CategoriesGrid extends StatelessWidget {
  const CategoriesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        // Row 1
        Row(
          children: [
            Expanded(
              child: _CategoryCard(
                title: 'Routine',
                titleColor: Colors.orange,
                todos: [
                  'Mop floor',
                  'Clean the bathr...',
                ],
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _CategoryCard(
                title: 'Groceries',
                titleColor: Colors.deepOrange,
                todos: [
                  'Yogurt',
                  'Ice cream',
                  'Turkey',
                ],
                showMoreCount: '+1',
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // Row 2
        Row(
          children: [
            Expanded(
              child: _CategoryCard(
                title: 'Gym',
                titleColor: Colors.purple,
                todos: [
                  '10 push ups',
                  '20 sit ups',
                ],
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _CategoryCard(
                title: 'Homework',
                titleColor: Color(0xFFF4A300),
                todos: [
                  'History assignm...',
                  'Fill a form',
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // Row 3
        Row(
          children: [
            Expanded(
              child: _CategoryCard(
                title: 'Bills',
                titleColor: Colors.blue,
                todos: [
                  'Pay rent',
                  'Water bill',
                ],
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _AddCategoryCard(),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final Color titleColor;
  final List<String> todos;
  final String? showMoreCount;

  const _CategoryCard({
    required this.title,
    required this.titleColor,
    required this.todos,
    this.showMoreCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 6),
          ...todos.map(
                (t) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                children: [
                  const _TodoCircle(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showMoreCount != null) ...[
            const SizedBox(height: 2),
            Text(
              showMoreCount!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 4),
          const Text(
            'New todo',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFB9B9B9),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodoCircle extends StatelessWidget {
  const _TodoCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFD0D0D0),
          width: 1.5,
        ),
      ),
    );
  }
}

class _AddCategoryCard extends StatelessWidget {
  const _AddCategoryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1.5,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.add,
          size: 30,
          color: Colors.grey,
        ),
      ),
    );
  }
}
