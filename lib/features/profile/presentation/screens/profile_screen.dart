import 'package:bond_app/features/auth/data/models/user_model.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:bond_app/features/profile/data/models/profile_model.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:bond_app/features/profile/presentation/widgets/profile_photo_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

/// Screen for displaying and editing user profile
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _occupationController = TextEditingController();
  final _educationController = TextEditingController();
  final _bioController = TextEditingController();
  final _relationshipStatusController = TextEditingController();
  final _lookingForController = TextEditingController();
  
  // Form values
  List<String> _languages = [];
  List<String> _hobbies = [];
  List<String> _skills = [];
  List<String> _personalityTraits = [];
  int? _height;
  bool _isPublic = true;
  
  @override
  void dispose() {
    _occupationController.dispose();
    _educationController.dispose();
    _bioController.dispose();
    _relationshipStatusController.dispose();
    _lookingForController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is Authenticated) {
            final user = authState.user;
            return _buildProfileContent(user);
          } else {
            return const Center(
              child: Text('You need to be logged in to view your profile'),
            );
          }
        },
      ),
    );
  }
  
  Widget _buildProfileContent(UserModel user) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is ProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        } else if (state is ProfilePhotoUploaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo uploaded successfully')),
          );
        } else if (state is ProfilePhotoDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo deleted successfully')),
          );
        }
      },
      builder: (context, state) {
        // Load profile when the screen is first built
        if (state is ProfileInitial) {
          context.read<ProfileBloc>().add(LoadProfile(user.id));
          return const Center(child: CircularProgressIndicator());
        }
        
        // Show loading indicator while profile is loading
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Show profile form when profile is loaded
        if (state is ProfileLoaded) {
          final profile = state.profile;
          _initializeFormValues(profile);
          return _buildProfileForm(user, profile);
        }
        
        // Show error message if profile loading fails
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load profile'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<ProfileBloc>().add(LoadProfile(user.id));
                },
                child: const Text('Retry'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final newProfile = ProfileModel.create(userId: user.id);
                  context.read<ProfileBloc>().add(CreateProfile(newProfile));
                },
                child: const Text('Create Profile'),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildProfileForm(UserModel user, ProfileModel profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header with user info
            _buildProfileHeader(user),
            
            const SizedBox(height: 24),
            
            // Profile photos section
            _buildPhotosSection(profile),
            
            const SizedBox(height: 24),
            
            // Basic info section
            _buildBasicInfoSection(),
            
            const SizedBox(height: 24),
            
            // Interests and skills section
            _buildInterestsAndSkillsSection(),
            
            const SizedBox(height: 24),
            
            // Personality traits section
            _buildPersonalityTraitsSection(),
            
            const SizedBox(height: 24),
            
            // Privacy settings
            _buildPrivacySettings(),
            
            const SizedBox(height: 32),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('Save Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader(UserModel user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: user.photoUrl != null 
              ? NetworkImage(user.photoUrl!) 
              : null,
          child: user.photoUrl == null 
              ? Text(user.displayName?[0] ?? user.email[0].toUpperCase()) 
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.displayName ?? 'No Name',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                user.email,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (user.phoneNumber != null)
                Text(
                  user.phoneNumber!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildPhotosSection(ProfileModel profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ProfilePhotoGrid(
          photos: profile.photos,
          onAddPhoto: _pickImage,
          onDeletePhoto: (photoUrl) {
            context.read<ProfileBloc>().add(
              DeleteProfilePhoto(profile.userId, photoUrl),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _occupationController,
          decoration: const InputDecoration(
            labelText: 'Occupation',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _educationController,
          decoration: const InputDecoration(
            labelText: 'Education',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _bioController,
          decoration: const InputDecoration(
            labelText: 'Bio',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _relationshipStatusController,
          decoration: const InputDecoration(
            labelText: 'Relationship Status',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _lookingForController,
          decoration: const InputDecoration(
            labelText: 'Looking For',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: _height?.toString() ?? '',
          decoration: const InputDecoration(
            labelText: 'Height (cm)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              _height = int.tryParse(value);
            });
          },
        ),
      ],
    );
  }
  
  Widget _buildInterestsAndSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interests & Skills',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildChipInputField(
          label: 'Languages',
          chips: _languages,
          onChanged: (values) {
            setState(() {
              _languages = values;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildChipInputField(
          label: 'Hobbies & Interests',
          chips: _hobbies,
          onChanged: (values) {
            setState(() {
              _hobbies = values;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildChipInputField(
          label: 'Skills',
          chips: _skills,
          onChanged: (values) {
            setState(() {
              _skills = values;
            });
          },
        ),
      ],
    );
  }
  
  Widget _buildPersonalityTraitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personality Traits',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildChipInputField(
          label: 'Personality Traits',
          chips: _personalityTraits,
          onChanged: (values) {
            setState(() {
              _personalityTraits = values;
            });
          },
        ),
      ],
    );
  }
  
  Widget _buildPrivacySettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Privacy Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Public Profile'),
          subtitle: const Text('Allow others to view your profile'),
          value: _isPublic,
          onChanged: (value) {
            setState(() {
              _isPublic = value;
            });
          },
        ),
      ],
    );
  }
  
  Widget _buildChipInputField({
    required String label,
    required List<String> chips,
    required Function(List<String>) onChanged,
  }) {
    final textController = TextEditingController();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: textController,
                decoration: const InputDecoration(
                  hintText: 'Add new item',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  final newList = List<String>.from(chips);
                  newList.add(textController.text);
                  onChanged(newList);
                  textController.clear();
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips.map((chip) {
            return Chip(
              label: Text(chip),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                final newList = List<String>.from(chips);
                newList.remove(chip);
                onChanged(newList);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
  
  void _initializeFormValues(ProfileModel profile) {
    _occupationController.text = profile.occupation ?? '';
    _educationController.text = profile.education ?? '';
    _bioController.text = profile.lookingFor ?? '';
    _relationshipStatusController.text = profile.relationshipStatus ?? '';
    _lookingForController.text = profile.lookingFor ?? '';
    _languages = profile.languages;
    _hobbies = profile.hobbies;
    _skills = profile.skills;
    _personalityTraits = profile.personalityTraits;
    _height = profile.height;
    _isPublic = profile.isPublic;
  }
  
  Future<void> _pickImage() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;
    
    final user = authState.state;
    
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      context.read<ProfileBloc>().add(
        UploadProfilePhoto(user.id, image.path),
      );
    }
  }
  
  void _saveProfile() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;
    
    final user = authState.user;
    final profileState = context.read<ProfileBloc>().state;
    
    if (profileState is ProfileLoaded) {
      final updatedProfile = profileState.profile.copyWith(
        occupation: _occupationController.text.isEmpty ? null : _occupationController.text,
        education: _educationController.text.isEmpty ? null : _educationController.text,
        bio: _bioController.text.isEmpty ? null : _bioController.text,
        relationshipStatus: _relationshipStatusController.text.isEmpty ? null : _relationshipStatusController.text,
        lookingFor: _lookingForController.text.isEmpty ? null : _lookingForController.text,
        languages: _languages,
        hobbies: _hobbies,
        skills: _skills,
        personalityTraits: _personalityTraits,
        height: _height,
        isPublic: _isPublic,
      );
      
      context.read<ProfileBloc>().add(UpdateProfile(updatedProfile));
    } else {
      // Create a new profile if one doesn't exist
      final newProfile = ProfileModel.create(
        userId: user.id,
      ).copyWith(
        occupation: _occupationController.text.isEmpty ? null : _occupationController.text,
        education: _educationController.text.isEmpty ? null : _educationController.text,
        bio: _bioController.text.isEmpty ? null : _bioController.text,
        relationshipStatus: _relationshipStatusController.text.isEmpty ? null : _relationshipStatusController.text,
        lookingFor: _lookingForController.text.isEmpty ? null : _lookingForController.text,
        languages: _languages,
        hobbies: _hobbies,
        skills: _skills,
        personalityTraits: _personalityTraits,
        height: _height,
        isPublic: _isPublic,
      );
      
      context.read<ProfileBloc>().add(CreateProfile(newProfile));
    }
  }
}
