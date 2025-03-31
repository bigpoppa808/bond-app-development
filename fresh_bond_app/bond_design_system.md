# Bond Design System (BondDS)

## Overview

The Bond Design System combines modern design trends of 2025 with user-centered principles to create a cohesive, engaging, and accessible social experience. This document outlines the key components and guidelines for implementing BondDS across the Bond application.

## Core Design Principles

1. **Connection-Focused**: Design elements that foster human connection and relationship building
2. **Emotional Intelligence**: Visual language that conveys warmth, trust, and emotional understanding
3. **Accessibility First**: Inclusive design that works for all users regardless of abilities
4. **Progressive Disclosure**: Present information in a manner that reduces cognitive load
5. **Playful Sophistication**: Professional yet engaging interface that delights without overwhelming

## Design Trends Implementation

### 1. Neo-Glassmorphism

A modern take on the glassmorphism trend featuring:
- Frosted glass effects with 65-70% opacity
- Subtle light source shadows (8-12px blur, 2-4px y-offset)
- Thin, bright borders (0.5-1px) for depth
- Backdrop filters with 15-20px blur values
- Subtle grain texture overlay (3-5% noise)

Neo-glassmorphism will be applied to cards, modal dialogs, and overlays to create depth while maintaining a premium feel.

### 2. Bento Box Layout System

A modular, grid-based layout system inspired by Japanese bento boxes:
- Section-based content organization
- Variable-sized content containers with consistent spacing (16px)
- Hierarchical information presentation
- Card-based UI components with clear boundaries
- Asymmetrical yet balanced composition

This layout system will be used for the home feed, discovery sections, and profile screens to organize diverse content types cohesively.

### 3. Tactile Micro-interactions

Responsive feedback system featuring:
- Spring physics animations (0.5-0.8s duration)
- Haptic feedback patterns for key actions
- Sound design for critical interactions (optional, user-configurable)
- Animated transitions between states (ease-in-out, 0.3-0.5s)
- Context-aware motion design

## Color System

### Primary Palette

The Bond color system uses a dynamic palette based on emotional connection psychology:

**Core Colors**:
- **Bond Teal** `#0ABAB5` - Primary brand color representing trust and stability
- **Connection Purple** `#6E44FF` - Secondary color representing creativity and connection
- **Warmth Orange** `#FF7D3B` - Accent color for calls-to-action and highlights
- **Trust Blue** `#2D7FF9` - Supporting color for security-related features

### Extended Palette

**Neutrals**:
- **Night** `#121F2B` - Deep background for dark mode
- **Slate** `#334155` - Secondary dark text and icons
- **Mist** `#94A3B8` - Tertiary text and disabled states
- **Cloud** `#E2E8F0` - Borders and separators
- **Snow** `#F8FAFC` - Background for light mode

**Semantic Colors**:
- **Success** `#10B981` - Positive actions and confirmations
- **Warning** `#FBBF24` - Cautionary indicators
- **Error** `#EF4444` - Critical errors and alerts
- **Info** `#3B82F6` - Informational messages

### Color Application

- 60% Neutral colors for backgrounds and containers
- 30% Primary/Secondary colors for UI elements and navigation
- 10% Accent colors for critical interactive elements

## Typography

### Font Family

**Primary**: "Satoshi" - A modern, geometric sans-serif with excellent readability
- Fallback: "SF Pro Text", "Roboto", system-ui

**Secondary**: "Cabinet Grotesk" - A slightly playful sans-serif for headlines and emphasis
- Fallback: "SF Pro Display", "Montserrat", sans-serif

### Type Scale

Using a fluid type scale based on a 1.2 ratio for mobile and 1.25 for larger screens:

| Style         | Mobile (px/weight) | Desktop (px/weight) | Usage                   |
|---------------|--------------------|--------------------|-------------------------|
| Display       | 36/700             | 48/700             | Hero sections           |
| Heading 1     | 28/700             | 36/700             | Main section headers    |
| Heading 2     | 22/600             | 28/600             | Section headers         |
| Heading 3     | 18/600             | 22/600             | Card headers            |
| Body Large    | 16/400             | 18/400             | Featured content        |
| Body          | 14/400             | 16/400             | Primary content         |
| Body Small    | 13/400             | 14/400             | Secondary content       |
| Caption       | 12/500             | 12/500             | Supporting text         |
| Button        | 14/600             | 16/600             | Interactive elements    |

## Component System

### Core Components

1. **BondCard**
   - Glass-effect container for content
   - Variable height, fixed width (matches column)
   - Rounded corners (16px)
   - Content padding (16px)
   - Optional hover states and animations

2. **BondButton**
   - Primary: Filled with brand gradient
   - Secondary: Outlined with brand color
   - Tertiary: Text-only with hover indication
   - Icon variant: Circle or pill shapes
   - Loading state with animated indicator

3. **BondInput**
   - Glass-effect background
   - Animated label transition
   - Contextual validation feedback
   - Adaptive keyboard support
   - Voice input option

4. **BondAvatar**
   - Circular or rounded square options
   - Status indicator position
   - Multiple size variants
   - Placeholder animation for loading
   - Group arrangement patterns

5. **BondNavigationBar**
   - Glass-effect background
   - Animated indicator for active section
   - Center-positioned main action button
   - Haptic feedback on selection
   - Collapsible/expandable states

### Advanced Components

1. **BondConnectionCard**
   - User info with compatibility indicators
   - Interactive elements for connection actions
   - Expandable detail view
   - Animated state transitions
   - Shared interest highlights

2. **BondNotificationItem**
   - Priority visual indicators
   - Timestamp with relative formatting
   - Action buttons for quick responses
   - Grouped notification collapsing
   - Read/unread visual states

3. **BondChatBubble**
   - Direction-based styling (sent/received)
   - Media embedding capabilities
   - Reaction support
   - Delivery status indicators
   - Contextual action menu

4. **BondProfileHeader**
   - Parallax effect on scroll
   - Presence indicator
   - Stats summary
   - Quick action buttons
   - Dynamic photo gallery

5. **BondVerificationCard**
   - NFC scan animation with ripple effect
   - Status indicators (scanning, success, error)
   - Color-coded feedback for verification states
   - Progress visualization for multi-step processes
   - Device proximity indication

## Motion and Animation

### Principles

1. **Purposeful**: Every animation serves a functional purpose
2. **Fluid**: Natural, physics-based movements
3. **Efficient**: Quick enough not to delay user interaction
4. **Cohesive**: Consistent timing and easing across the app
5. **Hierarchical**: Motion reflects information hierarchy

### Timing

- **Quick actions**: 100-200ms
- **Transitions**: 300-500ms
- **Complex animations**: 500-800ms
- **Idle animations**: 2000-3000ms with subtle looping

### Easing

- **Standard**: Cubic-bezier(0.4, 0.0, 0.2, 1)
- **Deceleration**: Cubic-bezier(0.0, 0.0, 0.2, 1)
- **Acceleration**: Cubic-bezier(0.4, 0.0, 1, 1)
- **Sharp**: Cubic-bezier(0.4, 0.0, 0.6, 1)

## Iconography

### Style

- Line weight: 1.5px for UI icons, 2px for navigation
- Corner radius: 2px for sharp corners, 8px for rounded elements
- Size increments: 16px, 24px, 32px, 48px
- Padding: 4px minimum padding within containers
- States: Regular, Active, Hover, Disabled

### Icon Sets

- **UI Icons**: Functional interface elements
- **Category Icons**: Visual indicators for content types
- **Notification Icons**: Status and alert indicators
- **Feature Icons**: Larger illustrations for onboarding and empty states
- **Emoji Reactions**: Custom expression system for social interactions

## Responsive Behavior

### Breakpoints

- **Mobile S**: 320px - 375px
- **Mobile L**: 376px - 428px
- **Tablet**: 429px - 768px
- **Desktop S**: 769px - 1024px
- **Desktop L**: 1025px and above

### Layout Shifts

- Mobile: Single column Bento layout
- Tablet: Two column Bento layout
- Desktop: Three column Bento layout with fixed navigation

### Component Adaptation

Components will automatically adapt to screen sizes with:
- Increased touch targets on mobile (min 44px)
- Condensed information on smaller screens
- Expanded detail views on larger screens
- Repositioned navigation for different devices

## Accessibility Guidelines

### Color Contrast

- Text meets WCAG 2.1 AA standards (4.5:1 for normal text, 3:1 for large text)
- Interactive elements have 3:1 contrast ratio against backgrounds
- Focus states have 3:1 contrast ratio against normal states

### Interaction Support

- All interactive elements accessible via keyboard
- Touch targets minimum 44x44px
- Screen reader support with semantic HTML
- Reduced motion option for animations
- Text scaling support up to 200%

### Content Guidelines

- Clear, concise language
- Reading level aimed at grade 8-10
- Consistent terminology across the application
- Helpful error messages with resolution suggestions
- Progressive disclosure for complex features

## Implementation Approach

### Component Library

- Build as a Flutter package for reusability
- Storybook documentation for all components
- Unit tests for component behavior
- Accessibility tests integrated into CI/CD
- Version control with semantic versioning

### Design Tokens

- JSON-based design tokens for all values
- Automated generation of platform-specific constants
- Dark/light mode token mapping
- Responsive token adjustments
- Theme customization capabilities

## Version Control

The Bond Design System will follow semantic versioning:
- **Major version**: Breaking changes requiring code updates
- **Minor version**: New features and components (backward compatible)
- **Patch version**: Bug fixes and minor adjustments

## Getting Started

Implementing the Bond Design System requires:
1. Installing the BondDS Flutter package
2. Importing the design tokens
3. Using the component library
4. Following the documented patterns and guidelines
5. Testing implementation against accessibility standards

---

This design system document serves as the foundation for all UI development within the Bond application. It should be treated as a living document that evolves alongside the product and user needs.
