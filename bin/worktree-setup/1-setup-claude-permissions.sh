#!/bin/bash
# Setup Claude Code permissions for worktree

set -e

mkdir -p .claude

cat > .claude/settings.local.json << 'EOF'
{
  "permissions": {
    "allow": [
      "Bash(mkdir -p **/specs/**)",
      "Bash(chmod:*)",
      "Bash(.specify/scripts/bash/check-prerequisites.sh:*)",
      "Bash(.specify/scripts/bash/common.sh:*)",
      "Bash(.specify/scripts/bash/create-new-feature.sh:*)",
      "Bash(.specify/scripts/bash/list-specs.sh:*)",
      "Bash(.specify/scripts/bash/set-current.sh:*)",
      "Bash(.specify/scripts/bash/setup-plan.sh:*)",
      "Bash(.specify/scripts/bash/update-agent-context.sh:*)",
      "Bash(command -v:*)",
      "Bash(shellcheck:*)"
    ]
  }
}
EOF

echo "Created .claude/settings.local.json with permissions"
