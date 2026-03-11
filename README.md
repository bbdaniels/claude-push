# Claude Push

Get Apple Watch haptic notifications when Claude Code needs attention.

**[Documentation](https://www.benjaminbdaniels.com/claude-push/)** | **[GitHub](https://github.com/bbdaniels/claude-push)**

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

## Setup

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

### 3. Install the Plugin

```bash
# Set your ntfy topic
export NTFY_TOPIC=your-topic-name

# Install the plugin
claude plugin add /path/to/claude-push
```

Or manually: copy the `hooks/hooks.json` entries into your `~/.claude/settings.json` hooks section, replacing `${NTFY_TOPIC}` with your actual topic name.

### 4. Manual Setup (Alternative)

Copy `hooks/ntfy-notify.sh` to `~/.claude/hooks/ntfy-notify.sh` and edit the `TOPIC` variable at the top. Then add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "AskUserQuestion",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/ntfy-notify.sh ask"
          }
        ]
      }
    ],
    "PermissionRequest": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/ntfy-notify.sh permission"
          }
        ]
      }
    ]
  }
}
```

### 5. Restart Claude Code

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

This instructs Claude to proactively ask questions, which triggers the `PreToolUse` hook that does work.

## What Works

| Hook | CLI | VSCode |
|------|-----|--------|
| PreToolUse (AskUserQuestion) | Yes | Yes |
| PostToolUse | Yes | Yes |
| Notification | Yes | No |
| PermissionRequest | Yes | No |

## License

MIT
