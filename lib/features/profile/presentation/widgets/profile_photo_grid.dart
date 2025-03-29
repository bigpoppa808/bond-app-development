import 'package:flutter/material.dart';

/// Widget for displaying a grid of profile photos with add and delete functionality
class ProfilePhotoGrid extends StatelessWidget {
  /// List of photo URLs
  final List<String> photos;
  
  /// Callback when the add photo button is tapped
  final VoidCallback onAddPhoto;
  
  /// Callback when a photo is deleted
  final Function(String) onDeletePhoto;
  
  /// Maximum number of photos allowed
  final int maxPhotos;

  /// Constructor
  const ProfilePhotoGrid({
    Key? key,
    required this.photos,
    required this.onAddPhoto,
    required this.onDeletePhoto,
    this.maxPhotos = 6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: photos.length < maxPhotos ? photos.length + 1 : maxPhotos,
      itemBuilder: (context, index) {
        // Add photo button
        if (index == photos.length && photos.length < maxPhotos) {
          return _buildAddPhotoButton(context);
        }
        
        // Photo item
        return _buildPhotoItem(context, photos[index]);
      },
    );
  }

  /// Build the add photo button
  Widget _buildAddPhotoButton(BuildContext context) {
    return GestureDetector(
      onTap: onAddPhoto,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(
            Icons.add_a_photo,
            color: Colors.grey,
            size: 32,
          ),
        ),
      ),
    );
  }

  /// Build a photo item with delete button
  Widget _buildPhotoItem(BuildContext context, String photoUrl) {
    return Stack(
      children: [
        // Photo
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(photoUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        // Delete button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => onDeletePhoto(photoUrl),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
