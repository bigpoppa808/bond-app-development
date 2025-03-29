import 'package:flutter/material.dart';

/// A widget for selecting the discovery radius
class RadiusSelector extends StatefulWidget {
  /// Current radius in meters
  final double currentRadius;
  
  /// Callback when radius is changed
  final Function(double) onRadiusChanged;
  
  /// Minimum radius in meters
  final double minRadius;
  
  /// Maximum radius in meters
  final double maxRadius;

  /// Constructor
  const RadiusSelector({
    Key? key,
    required this.currentRadius,
    required this.onRadiusChanged,
    this.minRadius = 1000, // 1 km
    this.maxRadius = 50000, // 50 km
  }) : super(key: key);

  @override
  State<RadiusSelector> createState() => _RadiusSelectorState();
}

class _RadiusSelectorState extends State<RadiusSelector> {
  late double _radius;
  
  @override
  void initState() {
    super.initState();
    _radius = widget.currentRadius;
  }
  
  @override
  void didUpdateWidget(RadiusSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRadius != widget.currentRadius) {
      _radius = widget.currentRadius;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Discovery Radius',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${(_radius / 1000).toStringAsFixed(1)} km',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('1 km'),
              Expanded(
                child: Slider(
                  value: _radius,
                  min: widget.minRadius,
                  max: widget.maxRadius,
                  divisions: 49, // 1 km increments
                  onChanged: (value) {
                    setState(() {
                      _radius = value;
                    });
                  },
                  onChangeEnd: (value) {
                    widget.onRadiusChanged(value);
                  },
                ),
              ),
              const Text('50 km'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPresetButton(5000), // 5 km
              _buildPresetButton(10000), // 10 km
              _buildPresetButton(25000), // 25 km
              _buildPresetButton(50000), // 50 km
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPresetButton(double radius) {
    final isSelected = _radius == radius;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _radius = radius;
        });
        widget.onRadiusChanged(radius);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).primaryColor.withOpacity(0.5),
          ),
        ),
        child: Text(
          '${(radius / 1000).toStringAsFixed(0)} km',
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
