#!/bin/bash
# Send ntfy notification with context extracted from stdin JSON
# Usage: echo '{"json":"..."}' | ntfy-notify.sh <hook_type>

# The Notification hook is redundant with PermissionRequest -- skip it
[ "$1" = "notification" ] && exit 0

TOPIC="${NTFY_TOPIC:?Set NTFY_TOPIC to your ntfy topic name}"
TITLE="Claude ($(basename "$PWD"))"
STAMPFILE="/tmp/ntfy-last-sent"

# Dedup: skip if sent within last 3 seconds
if [ -f "$STAMPFILE" ]; then
  LAST=$(cat "$STAMPFILE" 2>/dev/null || echo 0)
  NOW=$(date +%s)
  [ $((NOW - LAST)) -lt 3 ] && exit 0
fi
date +%s > "$STAMPFILE"

INPUT=$(cat)

BODY=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    hook = sys.argv[1] if len(sys.argv) > 1 else ''
    inp = d.get('tool_input', {})
    tool = d.get('tool_name', '')

    def get_question():
        qs = inp.get('questions', [])
        if qs:
            return qs[0].get('question', '')[:200]
        return inp.get('question', '')[:200]

    if hook == 'ask':
        print(get_question() or 'Has a question')
    elif hook == 'permission':
        desc = inp.get('description', '')
        cmd = inp.get('command', inp.get('file_path', ''))
        if desc:
            print(desc[:200])
        elif cmd:
            print(str(cmd)[:200])
        elif tool == 'AskUserQuestion':
            print(get_question() or 'Has a question')
        else:
            print(tool or 'Needs permission')
    else:
        print(tool or 'Needs attention')
except:
    print('Needs attention')
" "$1" 2>/dev/null)

curl -s -H "Title: $TITLE" -d "${BODY:- }" "ntfy.sh/$TOPIC" >/dev/null 2>&1
