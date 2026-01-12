# Claude Push

Get Apple Watch haptic notifications when Claude Code needs your attention.

## How It Works

```
Claude asks question (PreToolUse hook)
    → curl POST to Pushcut webhook
    → Pushcut sends push notification
    → iPhone/Apple Watch receives haptic ping
```

## Setup

### 1. Install Pushcut

1. Download [Pushcut](https://apps.apple.com/app/pushcut-shortcuts-automation/id1450936447) from the iOS App Store
2. Create a free account
3. Go to **Notifications** → tap **+**
4. Create a notification named `Claude` with sound and haptic enabled
5. Copy the webhook URL

### 2. Test the Webhook

```bash
curl -X POST "https://api.pushcut.io/YOUR_SECRET/notifications/Claude"
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
            "command": "curl -s -X POST 'https://api.pushcut.io/YOUR_SECRET/notifications/Claude'"
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

This instructs Claude to proactively ask questions, which triggers the `PreToolUse` hook that does work.

## What Works

| Hook | CLI | VSCode |
|------|-----|--------|
| PreToolUse (AskUserQuestion) | ✅ | ✅ |
| PostToolUse | ✅ | ✅ |
| Notification | ✅ | ❌ |
| PermissionRequest | ✅ | ❌ |

## License

MIT
