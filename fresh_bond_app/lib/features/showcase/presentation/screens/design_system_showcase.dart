import 'package:flutter/material.dart';
import '../../../../core/design/bond_colors.dart';
import '../../../../core/design/bond_typography.dart';
import '../../../../core/design/components/bond_avatar.dart';
import '../../../../core/design/components/bond_badge.dart';
import '../../../../core/design/components/bond_bottom_sheet.dart';
import '../../../../core/design/components/bond_button.dart';
import '../../../../core/design/components/bond_card.dart';
import '../../../../core/design/components/bond_chip.dart';
import '../../../../core/design/components/bond_dialog.dart';
import '../../../../core/design/components/bond_input.dart';
import '../../../../core/design/components/bond_list.dart';
import '../../../../core/design/components/bond_progress_indicator.dart';
import '../../../../core/design/components/bond_segmented_control.dart';
import '../../../../core/design/components/bond_tab_bar.dart';
import '../../../../core/design/components/bond_toast.dart';
import '../../../../core/design/components/bond_toggle.dart';

/// A showcase screen for the Bond Design System components
class DesignSystemShowcase extends StatefulWidget {
  const DesignSystemShowcase({Key? key}) : super(key: key);

  @override
  State<DesignSystemShowcase> createState() => _DesignSystemShowcaseState();
}

class _DesignSystemShowcaseState extends State<DesignSystemShowcase> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  bool _toggleValue = false;
  String _selectedSegment = 'All';
  double _progressValue = 0.3;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bond Design System'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              BondDialog.showAlert(
                context: context,
                title: 'About',
                message: 'This is a showcase of the Bond Design System components.',
                useGlassEffect: true,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'Typography',
            children: [
              Text('Display', style: BondTypography.display(context)),
              Text('Heading 1', style: BondTypography.heading1(context)),
              Text('Heading 2', style: BondTypography.heading2(context)),
              Text('Heading 3', style: BondTypography.heading3(context)),
              Text('Body Large', style: BondTypography.bodyLarge(context)),
              Text('Body', style: BondTypography.body(context)),
              Text('Body Small', style: BondTypography.bodySmall(context)),
              Text('Caption', style: BondTypography.caption(context)),
              Text('Button Text', style: BondTypography.button(context)),
            ],
          ),
          
          _buildSection(
            title: 'Colors',
            children: [
              _buildColorRow('Bond Teal', BondColors.bondTeal),
              _buildColorRow('Bond Purple', BondColors.bondPurple),
              _buildColorRow('Warmth Orange', BondColors.warmthOrange),
              _buildColorRow('Trust Blue', BondColors.trustBlue),
              _buildColorRow('Success', BondColors.success),
              _buildColorRow('Warning', BondColors.warning),
              _buildColorRow('Error', BondColors.error),
              _buildColorRow('Slate', BondColors.slate),
              _buildColorRow('Cloud', BondColors.cloud),
              _buildColorRow('Night', BondColors.night),
            ],
          ),
          
          _buildSection(
            title: 'Buttons',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  BondButton(
                    label: 'Primary',
                    onPressed: () {},
                    variant: BondButtonVariant.primary,
                  ),
                  BondButton(
                    label: 'Secondary',
                    onPressed: () {},
                    variant: BondButtonVariant.secondary,
                  ),
                  BondButton(
                    label: 'Outlined',
                    onPressed: () {},
                    variant: BondButtonVariant.secondary,
                  ),
                  BondButton(
                    label: 'Text',
                    onPressed: () {},
                    variant: BondButtonVariant.tertiary,
                  ),
                  BondButton(
                    label: 'Danger',
                    onPressed: () {},
                    variant: BondButtonVariant.primary,
                    useGlass: true,
                  ),
                  BondButton(
                    label: 'With Icon',
                    onPressed: () {},
                    icon: Icons.star,
                  ),
                  BondButton(
                    label: 'Loading',
                    onPressed: () {},
                    isLoading: true,
                  ),
                  BondButton(
                    label: 'Disabled',
                    onPressed: null,
                  ),
                ],
              ),
            ],
          ),
          
          _buildSection(
            title: 'Cards',
            children: [
              BondCard(
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Standard Card'),
                ),
              ),
              const SizedBox(height: 16),
              BondCard(
                blurAmount: 20.0,
                opacity: 0.8,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Glass Effect Card'),
                ),
              ),
            ],
          ),
          
          _buildSection(
            title: 'Avatars',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  BondAvatar(
                    size: BondAvatarSize.sm,
                    initials: 'JD',
                  ),
                  BondAvatar(
                    size: BondAvatarSize.md,
                    initials: 'JS',
                  ),
                  BondAvatar(
                    size: BondAvatarSize.lg,
                    initials: 'RJ',
                  ),
                  BondAvatar(
                    size: BondAvatarSize.md,
                    imageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
                  ),
                  BondAvatar(
                    size: BondAvatarSize.md,
                    initials: 'AB',
                    status: BondAvatarStatus.online,
                  ),
                  BondAvatar(
                    size: BondAvatarSize.md,
                    initials: 'BG',
                    status: BondAvatarStatus.away,
                  ),
                ],
              ),
            ],
          ),
          
          _buildSection(
            title: 'Inputs',
            children: [
              BondInput(
                label: 'Standard Input',
                placeholder: 'Enter text',
              ),
              const SizedBox(height: 16),
              BondInput(
                label: 'Password Input',
                placeholder: 'Enter password',
                obscureText: true,
              ),
              const SizedBox(height: 16),
              BondInput(
                label: 'Input with Icon',
                placeholder: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
              const SizedBox(height: 16),
              BondInput(
                label: 'Input with Validation',
                placeholder: 'Enter email',
                errorText: 'Please enter a valid email',
              ),
            ],
          ),
          
          _buildSection(
            title: 'Badges',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  BondBadge(
                    text: '1',
                  ),
                  BondBadge(
                    text: '99+',
                  ),
                  BondBadge(
                    text: 'New',
                    variant: BondBadgeVariant.success,
                  ),
                  BondBadge(
                    text: 'Warning',
                    variant: BondBadgeVariant.warning,
                  ),
                  BondBadge(
                    text: 'Error',
                    variant: BondBadgeVariant.error,
                  ),
                  BondBadge(
                    text: '',
                    icon: Icons.star,
                  ),
                ],
              ),
            ],
          ),
          
          _buildSection(
            title: 'Toggle',
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Toggle Switch'),
                  BondToggle(
                    value: _toggleValue,
                    onChanged: (value) {
                      setState(() {
                        _toggleValue = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          
          _buildSection(
            title: 'Chips',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  BondChip(
                    label: 'Standard',
                  ),
                  BondChip(
                    label: 'Selected',
                    selected: true,
                  ),
                  BondChip(
                    label: 'With Icon',
                    leadingIcon: Icons.star,
                  ),
                  BondChip(
                    label: 'Deletable',
                    deletable: true,
                    onDeleted: () {},
                  ),
                  BondChip(
                    label: 'With Avatar',
                    avatar: BondAvatar(
                      size: BondAvatarSize.sm,
                      initials: 'JD',
                    ),
                  ),
                  BondChip(
                    label: 'Outlined',
                    variant: BondChipVariant.outlined,
                  ),
                ],
              ),
            ],
          ),
          
          _buildSection(
            title: 'Tab Bar',
            children: [
              BondTabBar(
                tabs: [
                  BondTabItem(label: 'Home', icon: Icons.home),
                  BondTabItem(label: 'Search', icon: Icons.search),
                  BondTabItem(label: 'Profile', icon: Icons.person, badgeCount: 3),
                ],
                currentIndex: _selectedTabIndex,
                onTabSelected: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                    _tabController.animateTo(index);
                  });
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Center(child: Text('Home Tab Content')),
                    Center(child: Text('Search Tab Content')),
                    Center(child: Text('Profile Tab Content')),
                  ],
                ),
              ),
            ],
          ),
          
          _buildSection(
            title: 'Segmented Control',
            children: [
              BondSegmentedControl<String>(
                segments: [
                  BondSegment(label: 'All', value: 'All'),
                  BondSegment(label: 'Favorites', value: 'Favorites', icon: Icons.favorite),
                  BondSegment(label: 'Recent', value: 'Recent', icon: Icons.history),
                ],
                selectedValue: _selectedSegment,
                onSegmentSelected: (value) {
                  setState(() {
                    _selectedSegment = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Center(child: Text('Selected: $_selectedSegment')),
            ],
          ),
          
          _buildSection(
            title: 'Progress Indicators',
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  BondProgressIndicator(
                    variant: BondProgressVariant.circular,
                    value: _progressValue,
                    showPercentage: true,
                  ),
                  BondProgressIndicator(
                    variant: BondProgressVariant.linear,
                    value: _progressValue,
                  ),
                  BondProgressIndicator(
                    variant: BondProgressVariant.stepped,
                    value: _progressValue,
                    steps: 5,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Slider(
                value: _progressValue,
                onChanged: (value) {
                  setState(() {
                    _progressValue = value;
                  });
                },
              ),
            ],
          ),
          
          _buildSection(
            title: 'Lists',
            children: [
              BondList(
                showDividers: true,
                children: [
                  BondList.sectionHeader(context, title: 'Section 1'),
                  BondListItem(
                    title: 'Standard List Item',
                    subtitle: 'With subtitle',
                    leading: Icon(Icons.star),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  BondListItem(
                    title: 'Another List Item',
                    subtitle: 'Tap to see action',
                    leading: Icon(Icons.favorite),
                    onTap: () {
                      BondToast.success(
                        context,
                        message: 'Item tapped!',
                      );
                    },
                  ),
                  BondList.sectionHeader(context, title: 'Section 2'),
                  BondListItem(
                    variant: BondListItemVariant.card,
                    title: 'Card Style List Item',
                    subtitle: 'With card styling',
                    leading: BondAvatar(
                      size: BondAvatarSize.sm,
                      initials: 'JD',
                    ),
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  BondListItem(
                    variant: BondListItemVariant.glass,
                    title: 'Glass Effect List Item',
                    subtitle: 'With glass styling',
                    leading: Icon(Icons.bubble_chart),
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
          
          _buildSection(
            title: 'Dialog & Bottom Sheet',
            children: [
              Row(
                children: [
                  Expanded(
                    child: BondButton(
                      label: 'Show Dialog',
                      onPressed: () {
                        BondDialog.show(
                          context: context,
                          title: 'Sample Dialog',
                          content: const Text('This is a sample dialog with primary and secondary actions.'),
                          primaryAction: BondDialogAction(
                            label: 'Confirm',
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          secondaryAction: BondDialogAction(
                            label: 'Cancel',
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            isSecondary: true,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: BondButton(
                      label: 'Show Bottom Sheet',
                      onPressed: () {
                        BondBottomSheet.show(
                          context: context,
                          title: 'Sample Bottom Sheet',
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              BondListItem(
                                title: 'Option 1',
                                leading: Icon(Icons.photo),
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              BondListItem(
                                title: 'Option 2',
                                leading: Icon(Icons.camera_alt),
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              BondListItem(
                                title: 'Option 3',
                                leading: Icon(Icons.file_upload),
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          _buildSection(
            title: 'Toast Messages',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  BondButton(
                    label: 'Info Toast',
                    variant: BondButtonVariant.secondary,
                    onPressed: () {
                      BondToast.info(
                        context,
                        message: 'This is an info toast message',
                      );
                    },
                  ),
                  BondButton(
                    label: 'Success Toast',
                    variant: BondButtonVariant.secondary,
                    onPressed: () {
                      BondToast.success(
                        context,
                        message: 'This is a success toast message',
                      );
                    },
                  ),
                  BondButton(
                    label: 'Warning Toast',
                    variant: BondButtonVariant.secondary,
                    onPressed: () {
                      BondToast.warning(
                        context,
                        message: 'This is a warning toast message',
                      );
                    },
                  ),
                  BondButton(
                    label: 'Error Toast',
                    variant: BondButtonVariant.secondary,
                    onPressed: () {
                      BondToast.error(
                        context,
                        message: 'This is an error toast message',
                      );
                    },
                  ),
                  BondButton(
                    label: 'Glass Effect Toast',
                    variant: BondButtonVariant.secondary,
                    onPressed: () {
                      BondToast.info(
                        context,
                        message: 'This is a toast with glass effect',
                        title: 'Glass Effect',
                        useGlassEffect: true,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: BondTypography.heading2(context),
            textAlign: TextAlign.center,
          ),
        ),
        BondCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildColorRow(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Text(name),
          const Spacer(),
          Text('#${color.value.toRadixString(16).substring(2).toUpperCase()}'),
        ],
      ),
    );
  }
}
