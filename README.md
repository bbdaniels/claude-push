# Claude Push

Get Apple Watch haptic notifications when Claude Code needs your attention.

## How It Works

```
Claude asks question (PreToolUse hook)
    -> curl POST to ntfy.sh
    -> ntfy sends push notification
    -> iPhone/Apple Watch receives haptic ping
```

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

### 3. Configure Claude Code

Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "AskUserQuestion",
        "hooks": [
          {
            "type": "command",
            "command": "curl -s -d 'Claude needs your attention' ntfy.sh/YOUR_TOPIC"
          }
        ]
      }
    ]
  }
}
```

Replace `YOUR_TOPIC` with the topic you subscribed to in the ntfy app.

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
