# Quickstart: Spec Naming Scheme

## Overview

Spec directories now use the format `{YYMMDD}-{4-char-random}-{slug}` instead of sequential numbering.

**Old format**: `001-user-auth`, `002-payment-flow`
**New format**: `260131-a7k2-user-auth`, `260131-p9x3-payment-flow`

## Creating a New Spec

```bash
# Basic usage (generates short name from description)
/speckit.specify "Add user authentication system"
# Creates: specs/260131-a7k2-user-authentication/

# With custom short name
/speckit.specify "Implement OAuth2 for third-party login" --short-name "oauth-login"
# Creates: specs/260131-p9x3-oauth-login/
```

## Understanding the Format

```
260131-a7k2-user-auth
│      │    │
│      │    └── Slug (from description or --short-name)
│      └── 4-char random string (ensures uniqueness)
└── Date prefix (YYMMDD: Jan 31, 2026)
```

## Key Changes

| Before | After |
|--------|-------|
| `--number N` flag | Removed (date-based naming replaces it) |
| Sequential numbers (001, 002...) | Date prefix (260131, 260201...) |
| Manual number management | Automatic uniqueness via random string |

## Compatibility

- **Existing specs**: Old specs like `001-byobu-session-manager` continue to work
- **Listing**: `/speckit.switch` shows all specs regardless of format
- **No migration**: Both formats coexist indefinitely

## Collision Handling

If two specs with the same slug are created on the same day, the 4-character random string ensures uniqueness:

```
260131-a7k2-user-auth
260131-b3m9-user-auth  # Different random string
```

The system automatically regenerates the random string if a collision is detected (extremely rare with 1.6M combinations).
