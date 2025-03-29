import 'package:flutter/material.dart';

/// A widget for filtering discovery results by interests
class DiscoveryFilterBar extends StatefulWidget {
  /// Currently selected interests
  final List<String> selectedInterests;
  
  /// Callback when interests are changed
  final Function(List<String>) onInterestsChanged;

  /// Constructor
  const DiscoveryFilterBar({
    Key? key,
    required this.selectedInterests,
    required this.onInterestsChanged,
  }) : super(key: key);

  @override
  State<DiscoveryFilterBar> createState() => _DiscoveryFilterBarState();
}

class _DiscoveryFilterBarState extends State<DiscoveryFilterBar> {
  // Common interests to filter by
  // This could be fetched from a repository in a real app
  final List<String> _commonInterests = [
    'Travel',
    'Music',
    'Sports',
    'Food',
    'Art',
    'Photography',
    'Reading',
    'Gaming',
    'Technology',
    'Fitness',
    'Movies',
    'Nature',
    'Cooking',
    'Fashion',
    'Dancing',
  ];
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: Text(
            'Filter by interests',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: [
              // Add custom interest chip
              GestureDetector(
                onTap: () => _showCustomInterestDialog(context),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        size: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Custom',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Interest chips
              ..._commonInterests.map((interest) {
                final isSelected = widget.selectedInterests.contains(interest);
                return GestureDetector(
                  onTap: () {
                    final newSelectedInterests = List<String>.from(widget.selectedInterests);
                    if (isSelected) {
                      newSelectedInterests.remove(interest);
                    } else {
                      newSelectedInterests.add(interest);
                    }
                    widget.onInterestsChanged(newSelectedInterests);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          interest,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
              
              // Clear all button if any interests are selected
              if (widget.selectedInterests.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    widget.onInterestsChanged([]);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.clear,
                          size: 18,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Clear All',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  void _showCustomInterestDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Interest'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter interest',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final interest = controller.text.trim();
              if (interest.isNotEmpty) {
                final newSelectedInterests = List<String>.from(widget.selectedInterests);
                if (!newSelectedInterests.contains(interest)) {
                  newSelectedInterests.add(interest);
                  widget.onInterestsChanged(newSelectedInterests);
                }
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
