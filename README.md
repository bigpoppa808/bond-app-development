# Bond App Development

![Bond App](https://img.shields.io/badge/Bond-Social%20Meeting%20App-blue?style=for-the-badge&logo=react)
![Flutter](https://img.shields.io/badge/Flutter-Latest-02569B?style=for-the-badge&logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?style=for-the-badge&logo=firebase)

## Overview

Bond is a social meeting application designed to connect users based on compatibility, shared interests, and real-time availability. The app facilitates meaningful in-person connections through a token-based incentive system and NFC verification.

<div align="center">
  <img src="https://raw.githubusercontent.com/bigpoppa808/bond-app-development/main/assets/bond-app-logo.svg" alt="Bond App Logo" width="200"/>
</div>

## Core Features

- **User Authentication**: Secure login with email/password and social login options
- **User Profiles**: Customizable profiles with interests and availability settings
- **Discovery**: Find compatible users nearby using location services
- **Connections**: Send and manage connection requests
- **Meetings**: Schedule and coordinate in-person meetings
- **NFC Verification**: Verify meetings happened in person
- **Token Economy**: Earn tokens for verified meetings
- **Donor Subscriptions**: Premium features for subscribers

## Architecture

Bond uses a layered architecture with BLoC pattern for state management:

<div align="center">
  <img src="https://mermaid.ink/svg/pako:eNp1ksFuwjAMhl_F8qkgwQvsQKUNaRNDGmxj2g6-pMYNURunyxJQx949KYWxwXpK_H_-bMc5QmYkQgSvtdHUCHnRZJlWJFwjqVJKGFpJZWwpSgfPUhfCOKGVXLdCNZIcvGhTbmCXy3XlBFe0Fq5Vb9KQg_vhHmFX6lJIB4_S5Nt_lXPwIk2-6_kO7rvQwQmRLvdEDh6kKfYXqvkfqtQVkYM3qYtjz3fwJE2xv1DNf1ClrogcvEtTHHq-g2dpikPPd_AiTXHs-Q5epSn2Pd_BmzTFoec7-JCm2PV8B5_SFLue7-BLmmLb8x18S1Nser6DH2mKTc938CtNsen5Dn6lKdY938GfNMW65zv4l6ZY9XwHf9IUq57vYNWGZdgFRFBQRWkDEVZMU9pCNIcYYjTMUMoUxFBTw5jCCKJJO8QIYsYZNZRkEK1oYWnLKJtBtKCWUbqEKGvnUVZDlHOeQMSNNpQbzFOIeNnFTfEPGMgKWQ" alt="Bond Architecture" width="600"/>
</div>

## Folder Structure

The project follows a feature-first folder structure:

<div align="center">
  <img src="https://mermaid.ink/svg/pako:eNqNksFuwjAMhl_F8qkgwQvsQKUNaRNDGmxj2g6-pMYNURunyxJQx949KYWxwXpK_H_-bMc5QmYkQgSvtdHUCHnRZJlWJFwjqVJKGFpJZWwpSgfPUhfCOKGVXLdCNZIcvGhTbmCXy3XlBFe0Fq5Vb9KQg_vhHmFX6lJIB4_S5Nt_lXPwIk2-6_kO7rvQwQmRLvdEDh6kKfYXqvkfqtQVkYM3qYtjz3fwJE2xv1DNf1ClrogcvEtTHHq-g2dpikPPd_AiTXHs-Q5epSn2Pd_BmzTFoec7-JCm2PV8B5_SFLue7-BLmmLb8x18S1Nser6DH2mKTc938CtNsen5Dn6lKdY938GfNMW65zv4l6ZY9XwHf9IUq57vYNWGZdgFRFBQRWkDEVZMU9pCNIcYYjTMUMoUxFBTw5jCCKJJO8QIYsYZNZRkEK1oYWnLKJtBtKCWUbqEKGvnUVZDlHOeQMSNNpQbzFOIeNnFTfEPGMgKWQ" alt="Bond Folder Structure" width="600"/>
</div>

## Data Models

The app uses the following data models:

<div align="center">
  <img src="https://mermaid.ink/svg/pako:eNqtVMFuwjAM_RUrp4IEX7ADlTakTQxpsI1pO_iSGjdEbZwuS0Ad_z5TYGxIE5p2Svz8_Gw7zgkyIxEieK2NpkbIiybLtCLhGkmVUsLQSipjS1E6eJa6EMYJreS6FaqR5OBFm3IDu1yuKye4orVwrXqThhy8DPcIu1KXQjp4lCbf_qucgxdp8l3Pd_DQhQ5OiHS5J3LwIE2xv1DN_1ClrogcvEldHHu-gydpiv2Fav6DKnVF5OBd6uLQ8x08S1Mcer6DF2mKY8938CpNse_5Dt6kKQ4938GHNMWu5zv4lKbY9XwHX9IU257v4FuaYtPzHfxIU2x6voNfaYpNz3fwK02x7vkO_qQp1j3fwb80xarnO_iTplj1fAerNizDLiCCgipKG4iwYprSFqI5xBCjYYZSpiCGmhrGFEYQTdohRhAzzqihJINoRQtLW0bZDKIFtYzSJURZO4-yGqKc8wQibrSh3GCeQsTLLm6KfwBWMQpZ" alt="Bond Data Models" width="700"/>
</div>

## Implementation Phases

The development plan is divided into five phases:

1. **Core Foundation & Authentication** (3 Months)
2. **Discovery, Connections & Basic Meetings** (2 Months)
3. **Enhanced Features & Messaging** (2 Months)
4. **Premium Features & Refinement** (2 Months)
5. **Testing, Launch Prep & Release** (1 Month)

## Getting Started

1. Clone the repository
   ```bash
   git clone https://github.com/bigpoppa808/bond-app-development.git
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Set up Firebase
   - Create a new Firebase project
   - Add your app to the Firebase project
   - Download and add the configuration files
   - Enable required Firebase services (Auth, Firestore, Functions, Storage)

4. Run the app
   ```bash
   flutter run
   ```

## Documentation

For detailed information, refer to the [Development Plan](development_plan.md) which includes:

- Technical architecture
- Folder structure
- Data models
- Implementation phases
- Technical considerations
- Risk management
- Project assumptions

## License

This project is proprietary and confidential.
