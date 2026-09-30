# Claude Code status line: model · dir · skills loaded this session · ponytail flag.
# Reads the status JSON on stdin; skills come from the session transcript.
input=$(cat)
model=$(jq -r '.model.display_name // empty' <<<"$input")
dir=$(jq -r '.workspace.current_dir // .cwd // empty' <<<"$input")
transcript=$(jq -r '.transcript_path // empty' <<<"$input")

line="$model · ${dir##*/}"

if [ -f "$transcript" ]; then
  # Model-invoked: Skill tool calls. User-invoked (/name): meta user entry holding the skill body.
  skills=$(
    { grep -E '"name":"Skill"|Base directory for this skill' "$transcript" || true; } \
      | jq -rR '
          fromjson? |
          if .type == "assistant" then
            .message.content[]? | select(.type? == "tool_use" and .name == "Skill") | .input.skill
          elif .type == "user" and .isMeta == true then
            .message.content[0].text? // empty
            | select(startswith("Base directory for this skill: "))
            | split("\n")[0] | split("/")[-1]
          else empty end' \
      | sed 's/^.*://' | awk 'NF && !seen[$0]++' | paste -sd, - | sed 's/,/, /g'
  )
  [ -n "$skills" ] && line="$line · skills: $skills"
fi

printf '%s' "$line"

ponytail="$HOME/.claude/skills/ponytail/hooks/ponytail-statusline.sh"
[ -f "$ponytail" ] && printf ' ' && bash "$ponytail"
exit 0
