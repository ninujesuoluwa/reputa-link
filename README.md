# ReputaLink - Next-Generation Social Proof Protocol

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Stacks](https://img.shields.io/badge/Built%20on-Stacks-orange.svg)](https://stacks.co)
[![Clarity](https://img.shields.io/badge/Smart%20Contract-Clarity-green.svg)](https://clarity-lang.org)

## Overview

ReputaLink is a revolutionary blockchain-based social validation ecosystem that transforms how trust and credibility are built in digital communities. Built on the Stacks blockchain and secured by Bitcoin, ReputaLink creates tamper-proof social interactions, skill validations, and reputation scoring systems.

## Key Features

- **Immutable Reputation Tracking**: Weighted endorsements permanently recorded on the blockchain
- **Incentivized Content Creation**: Algorithmic rewards based on engagement and reputation
- **Decentralized Skill Validation**: Peer-to-peer endorsement system with reputation-weighted validation
- **Anti-Spam Protection**: Reputation-based gatekeeping mechanisms
- **Community-Driven Moderation**: Distributed content curation and moderation tools

## System Architecture

### Core Components

```
┌─────────────────────────────────────────────────────────────┐
│                    ReputaLink Protocol                       │
├─────────────────────────────────────────────────────────────┤
│  User Management  │  Content Engine  │  Endorsement System  │
│  ┌─────────────┐  │  ┌─────────────┐  │  ┌─────────────┐     │
│  │ User Profiles│  │  │ Post System │  │  │ Peer Reviews│     │
│  │ Registration │  │  │ Interactions│  │  │ Skill Validation│ │
│  │ Verification │  │  │ Rewards     │  │  │ Weight Calc │     │
│  └─────────────┘  │  └─────────────┘  │  └─────────────┘     │
├─────────────────────────────────────────────────────────────┤
│               Reputation Scoring Engine                     │
├─────────────────────────────────────────────────────────────┤
│                 Stacks Blockchain Layer                     │
└─────────────────────────────────────────────────────────────┘
```

### Data Architecture

The contract implements a sophisticated data structure system:

#### User Management Layer

- **User Profiles**: Complete user metadata with reputation tracking
- **Identity Mapping**: Bidirectional lookup between addresses and user IDs
- **Verification System**: Admin-controlled user verification process

#### Content Management Layer

- **Post Storage**: Rich content with metadata and engagement metrics
- **Interaction Tracking**: Like, repost, and reply tracking systems
- **Tag System**: Categorization and discoverability features

#### Reputation System

- **Endorsement Engine**: Weighted peer-to-peer skill validation
- **Reputation Calculation**: Dynamic scoring based on multiple factors
- **History Ledger**: Immutable audit trail of reputation changes

## Data Flow

### User Registration Flow

```
User Registration → Profile Creation → ID Assignment → Blockchain Storage
```

### Content Creation Flow

```
Content Creation → Validation → Blockchain Storage → Engagement Tracking
```

### Reputation Flow

```
User Actions → Reputation Calculation → Weight Application → Score Update
```

### Endorsement Flow

```
Endorsement Request → Validation → Weight Calculation → Reputation Update
```

## Smart Contract Functions

### User Management

- `register-user`: Create new user profile with initial reputation
- `update-profile`: Modify user information and bio
- `verify-user`: Admin function for user verification

### Content Operations

- `create-post`: Publish content with tags and metadata
- `like-post`: Engage with content and trigger reputation rewards
- `repost`: Share content with attribution tracking

### Endorsement System

- `endorse-user`: Validate peer skills with weighted reputation impact
- `deactivate-endorsement`: Remove endorsements (author/admin only)

### Query Functions

- `get-user`: Retrieve user profile and statistics
- `get-post`: Access post data and engagement metrics
- `get-platform-stats`: Platform-wide analytics and metrics

## Reputation Mechanics

### Reputation Scoring Algorithm

The platform uses a multi-factor reputation system:

1. **Base Reputation**: Starting score of 50 points
2. **Content Rewards**: Dynamic rewards based on engagement
3. **Endorsement Weights**: Reputation-based endorsement values
4. **Engagement Multipliers**: High-reputation users receive bonus rewards

### Endorsement Weight Calculation

```
Endorser Reputation ≥ 1000: 50 points
Endorser Reputation ≥ 500:  30 points
Endorser Reputation ≥ 100:  20 points
Default:                     10 points
```

### Anti-Gaming Measures

- **Self-Endorsement Prevention**: Users cannot endorse themselves
- **Duplicate Prevention**: One endorsement per user pair
- **Reputation Thresholds**: Minimum reputation required for certain actions
- **Moderation Tools**: Admin and user-controlled content deactivation

## Security Features

### Input Validation

- String length validation for all text inputs
- Tag list validation and sanitization
- UTF-8 and ASCII encoding compliance

### Access Control

- Owner-only administrative functions
- User-specific content management
- Reputation-based action gating

### Data Integrity

- Immutable blockchain storage
- Comprehensive error handling
- State validation checks

## Platform Economics

### Fee Structure

- Platform fee: 1% (100 basis points) - configurable by admin
- Minimum reputation for rewards: 100 points - configurable

### Reward Distribution

- Like-based rewards with reputation multipliers
- Content quality incentivization
- Long-term engagement rewards

## Getting Started

### Prerequisites

- Stacks wallet (Hiro Wallet recommended)
- STX tokens for transaction fees
- Understanding of Clarity smart contracts

### Deployment

1. Deploy the contract to Stacks testnet/mainnet
2. Set initial platform parameters
3. Configure admin permissions
4. Initialize user registration

### Integration

```javascript
// Example integration with Stacks.js
import { ContractCallOptions } from '@stacks/transactions';

const registerUser = async (username, bio) => {
  const options = {
    contractAddress: 'CONTRACT_ADDRESS',
    contractName: 'reputalink',
    functionName: 'register-user',
    functionArgs: [username, bio],
    // ... other options
  };
  return await makeContractCall(options);
};
```

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 100  | `err-owner-only` | Function restricted to contract owner |
| 101  | `err-not-found` | Requested resource not found |
| 102  | `err-already-exists` | Resource already exists |
| 103  | `err-unauthorized` | Insufficient permissions |
| 104  | `err-invalid-input` | Invalid input parameters |
| 105  | `err-insufficient-reputation` | Reputation below required threshold |
| 106  | `err-self-endorsement` | Cannot endorse oneself |
| 107  | `err-already-endorsed` | Endorsement already exists |

## Roadmap

- [ ] Advanced analytics and insights
- [ ] Multi-chain reputation bridging
- [ ] Governance token integration
- [ ] Mobile SDK development
- [ ] Enterprise partnership tools

## Contributing

We welcome contributions to ReputaLink! Please read our contributing guidelines and submit pull requests for review.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
