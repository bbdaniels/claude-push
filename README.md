# Claude Push

> **Deprecated.** Push notification support has been merged into [ClaudeHUD](https://github.com/bbdaniels/ClaudeHUD), a native macOS menu bar app for Claude Code. No manual hook setup needed -- just toggle the bell icon in the HUD header.

---

Get Apple Watch haptic notifications when Claude Code needs attention.

## Migration

If you were using `claude-push`, you can replace it entirely with [ClaudeHUD](https://github.com/bbdaniels/ClaudeHUD):

1. Clone and build ClaudeHUD
2. Click the **bell icon** in the header
3. Enable desktop and/or mobile notifications
4. For mobile: enter your ntfy topic name and click Set

ClaudeHUD installs the hook script and manages `~/.claude/settings.json` automatically. You can remove any existing `ntfy-notify.sh` entries from your hooks config.

---

The original documentation is preserved below for reference.

## How It Works

```
Claude needs attention (permission, question, etc.)
    -> hook calls ntfy-notify.sh
    -> extracts context (question text, tool name, command description)
    -> sends push via ntfy.sh
    -> iPhone/Apple Watch receives haptic ping
```

Notifications show `Claude (project-name)` as the title, with a human-readable summary as the body -- the actual question for AskUserQuestion, or `Bash: description` for commands. Duplicate notifications from overlapping hooks are suppressed.

## Why ntfy

- No account required
- No API key
- No webhook URL to copy
- Just pick a topic name and go

## Setup (manual, legacy)

### 1. Install ntfy

1. Download [ntfy](https://apps.apple.com/app/ntfy/id1625396347) from the iOS App Store
2. Open the app and tap **+** to subscribe to a topic
3. Choose a topic name -- use a random suffix to keep it private (e.g. `claude-yourname-a1b2c3`)

Topics on ntfy.sh are public. Anyone who knows your topic name can send you notifications. A random suffix makes it effectively private.

### 2. Test It

```bash
curl -d "test" ntfy.sh/YOUR_TOPIC
```

You should receive a notification on your phone/watch.

### 3. Manual Setup

Copy `hooks/ntfy-notify.sh` to `~/.claude/hooks/ntfy-notify.sh` and add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "AskUserQuestion",
        "hooks": [
          {
            "type": "command",
            "command": "NTFY_TOPIC=your-topic ~/.claude/hooks/ntfy-notify.sh ask"
          }
        ]
      }
    ],
    "PermissionRequest": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "NTFY_TOPIC=your-topic ~/.claude/hooks/ntfy-notify.sh permission"
          }
        ]
      }
    ]
  }
}
```

### 4. Restart Claude Code

Hooks take effect after restart.

## VSCode Limitation

**Important:** The `PermissionRequest` and `Notification` hooks don't work in the VSCode extension due to a [known bug (#8985)](https://github.com/anthropics/claude-code/issues/8985).

### Workaround

Add this to your `~/.claude/CLAUDE.md`:

```markdown
## Push Notifications (VSCode)

When working in VSCode, use `AskUserQuestion` to confirm before taking
significant actions that would normally require permission. This triggers
a push notification to alert the user on their Apple Watch.
```

## What Works

| Hook | CLI | VSCode |
|------|-----|--------|
| PreToolUse (AskUserQuestion) | Yes | Yes |
| PostToolUse | Yes | Yes |
| Notification | Yes | No |
| PermissionRequest | Yes | No |

## License

MIT
