import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class AdvancedHabitScreen extends StatefulWidget {
  const AdvancedHabitScreen({super.key});

  @override
  State<AdvancedHabitScreen> createState() => _AdvancedHabitScreenState();
}

class _AdvancedHabitScreenState extends State<AdvancedHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetValueController = TextEditingController();

  String _selectedFrequency = 'daily';
  String _selectedDifficulty = 'medium';
  String _selectedCategory = 'health';
  String _selectedUnit = 'times';
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.check_circle;

  final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.deepOrange,
    Colors.lime,
  ];

  final List<IconData> _icons = [
    Icons.check_circle,
    Icons.fitness_center,
    Icons.book,
    Icons.water_drop,
    Icons.bedtime,
    Icons.directions_run,
    Icons.self_improvement,
    Icons.local_dining,
    Icons.psychology,
    Icons.favorite,
    Icons.school,
    Icons.groups,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  void _createAdvancedHabit() {
    if (_formKey.currentState!.validate()) {
      final habit = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'frequency': _selectedFrequency,
        'difficulty': _selectedDifficulty,
        'category': _selectedCategory,
        'targetValue': _targetValueController.text.isNotEmpty
            ? int.tryParse(_targetValueController.text) ?? 1
            : 1,
        'unit': _selectedUnit,
        'reminderTime':
            '${_reminderTime.hour}:${_reminderTime.minute.toString().padLeft(2, '0')}',
        'color': _selectedColor.value,
        'icon': _selectedIcon.codePoint,
        'isAdvanced': true,
        'createdAt': DateTime.now(),
      };

      Navigator.of(context).pop(habit);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createAdvancedHabit),
        backgroundColor: colorScheme.surfaceContainerHighest,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              _buildSectionTitle(l10n.habitName, theme),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.habitName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(
                    0.3,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Alışkanlık adı gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.habitDescription,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(
                    0.3,
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Frequency Section
              _buildSectionTitle(l10n.frequency, theme),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'daily', label: Text(l10n.daily)),
                  ButtonSegment(value: 'weekly', label: Text(l10n.weekly)),
                  ButtonSegment(value: 'monthly', label: Text(l10n.monthly)),
                ],
                selected: {_selectedFrequency},
                onSelectionChanged: (Set<String> selection) {
                  setState(() {
                    _selectedFrequency = selection.first;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Target & Unit Section
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(l10n.targetValue, theme),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _targetValueController,
                          decoration: InputDecoration(
                            labelText: l10n.targetValue,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(l10n.unit, theme),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedUnit,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'times',
                              child: Text(l10n.times),
                            ),
                            DropdownMenuItem(
                              value: 'minutes',
                              child: Text(l10n.minutes),
                            ),
                            DropdownMenuItem(
                              value: 'pages',
                              child: Text(l10n.pages),
                            ),
                            DropdownMenuItem(
                              value: 'glasses',
                              child: Text(l10n.glasses),
                            ),
                            DropdownMenuItem(
                              value: 'steps',
                              child: Text(l10n.steps),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedUnit = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Category Section
              _buildSectionTitle(l10n.category, theme),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildCategoryChip(
                    'health',
                    l10n.health,
                    Icons.favorite,
                    colorScheme,
                  ),
                  _buildCategoryChip(
                    'fitness',
                    l10n.fitness,
                    Icons.fitness_center,
                    colorScheme,
                  ),
                  _buildCategoryChip(
                    'productivity',
                    l10n.productivity,
                    Icons.work,
                    colorScheme,
                  ),
                  _buildCategoryChip(
                    'mindfulness',
                    l10n.mindfulness,
                    Icons.self_improvement,
                    colorScheme,
                  ),
                  _buildCategoryChip(
                    'education',
                    l10n.education,
                    Icons.school,
                    colorScheme,
                  ),
                  _buildCategoryChip(
                    'social',
                    l10n.social,
                    Icons.groups,
                    colorScheme,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Difficulty Section
              _buildSectionTitle(l10n.difficulty, theme),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'easy',
                    label: Text(l10n.easy),
                    icon: const Icon(Icons.sentiment_satisfied),
                  ),
                  ButtonSegment(
                    value: 'medium',
                    label: Text(l10n.medium),
                    icon: const Icon(Icons.sentiment_neutral),
                  ),
                  ButtonSegment(
                    value: 'hard',
                    label: Text(l10n.hard),
                    icon: const Icon(Icons.sentiment_very_dissatisfied),
                  ),
                ],
                selected: {_selectedDifficulty},
                onSelectionChanged: (Set<String> selection) {
                  setState(() {
                    _selectedDifficulty = selection.first;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Reminder Time Section
              _buildSectionTitle(l10n.reminderTime, theme),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_drop_down,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Color Selection
              _buildSectionTitle('Renk', theme),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _colors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.outline
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Icon Selection
              _buildSectionTitle('İkon', theme),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _icons.map((icon) {
                  final isSelected = _selectedIcon == icon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor.withOpacity(0.2)
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? _selectedColor
                              : colorScheme.outline,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? _selectedColor
                            : colorScheme.onSurfaceVariant,
                        size: 28,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _createAdvancedHabit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: _selectedColor,
                  ),
                  child: Text(
                    l10n.create,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildCategoryChip(
    String value,
    String label,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    final isSelected = _selectedCategory == value;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      avatar: Icon(icon, size: 18),
      onSelected: (selected) {
        setState(() {
          _selectedCategory = value;
        });
      },
      selectedColor: _selectedColor.withOpacity(0.2),
      checkmarkColor: _selectedColor,
    );
  }
}
