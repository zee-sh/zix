#!/usr/bin/env bash
# Claude Code statusLine — Starship + context zones + cost + rate limits + compaction + PR links

input=$(cat)

# Extract current directory from JSON
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')
[ -z "$cwd" ] && exit 0

# --- Catppuccin Mocha palette ---
GREEN='\033[38;2;166;227;161m'       # #a6e3a1
BOLD_GREEN='\033[1;38;2;166;227;161m'
YELLOW='\033[38;2;249;226;175m'      # #f9e2af
BOLD_YELLOW='\033[1;38;2;249;226;175m'
RED='\033[38;2;243;139;168m'         # #f38ba8
BOLD_RED='\033[1;38;2;243;139;168m'
PEACH='\033[38;2;250;179;135m'       # #fab387
BLUE='\033[38;2;137;180;250m'        # #89b4fa
MAUVE='\033[38;2;203;166;247m'       # #cba6f7
SUBTEXT='\033[38;2;166;173;200m'     # #a6adc8
OVERLAY='\033[38;2;147;153;178m'     # #9399b2
DIM='\033[2m'
RESET='\033[0m'

# --- Workspace emoji ---
get_workspace_emoji() {
    local bn=$(basename "$1")
    case "$bn" in
        *rust*|*cargo*)    echo "🦀" ;;
        *node*|*react*|*next*) echo "📦" ;;
        *python*|*py*)     echo "🐍" ;;
        *go*|*golang*)     echo "🐹" ;;
        *java*)            echo "☕" ;;
        *docker*)          echo "🐳" ;;
        *web*|*site*)      echo "🌐" ;;
        *api*)             echo "🔌" ;;
        *docs*)            echo "📚" ;;
        *test*)            echo "🧪" ;;
        *infra*|*pulumi*|*terraform*) echo "🏗️" ;;
        *harness*)         echo "⚙️" ;;
        *)
            local emojis=("💼" "📁" "🛠️" "⚙️" "🔧" "📊" "🎯" "🚀" "💡" "🔬")
            local hash=$(echo -n "$1" | cksum | cut -d' ' -f1)
            echo "${emojis[$((hash % ${#emojis[@]}))]}"
            ;;
    esac
}
workspace_emoji=$(get_workspace_emoji "$cwd")

# --- Starship prompt ---
export PWD="$cwd"
export STARSHIP_SHELL="bash"
cd "$cwd" 2>/dev/null || cd "$HOME"

starship_output=$(starship prompt 2>/dev/null | sed 's/\\\[//g; s/\\\]//g; s/\\\$/$/g' | tr -d '\n')
starship_right=$(starship prompt --right 2>/dev/null | sed 's/\\\[//g; s/\\\]//g; s/\\\$/$/g' | tr -d '\n')

# --- Extract JSON fields (single jq call) ---
eval "$(echo "$input" | jq -r '
  @sh "model_name=\(.model.display_name // "")",
  @sh "used_pct=\(.context_window.used_percentage // "")",
  @sh "ctx_size=\(.context_window.context_window_size // "")",
  @sh "cost_usd=\(.cost.total_cost_usd // "")",
  @sh "duration_ms=\(.cost.total_duration_ms // "")",
  @sh "lines_add=\(.cost.lines_added // "")",
  @sh "lines_rm=\(.cost.lines_removed // "")",
  @sh "rl5_pct=\(.rate_limits.five_hour.used_percentage // "")",
  @sh "rl5_reset=\(.rate_limits.five_hour.resets_at // "")",
  @sh "rl7_pct=\(.rate_limits.seven_day.used_percentage // "")",
  @sh "rl7_reset=\(.rate_limits.seven_day.resets_at // "")",
  @sh "session_id=\(.session_id // "")"
' 2>/dev/null)"

# --- Model, then context % with zone warnings (separate segments) ---
model_part=""
ctx_part=""
if [ -n "$model_name" ]; then
    model_part=$(printf "${SUBTEXT}%s${RESET}" "$model_name")
    if [ -n "$used_pct" ]; then
        used_int=$(printf "%.0f" "$used_pct")
        if [ "$used_int" -ge 60 ]; then
            ctx_color="$BOLD_RED"
        elif [ "$used_int" -ge 40 ]; then
            ctx_color="$BOLD_YELLOW"
        else
            ctx_color="$GREEN"
        fi
        ctx_part=$(printf "${SUBTEXT}Context:${ctx_color}%s%%${RESET}" "$used_int")
        # Absolute tokens: "105k/1M" (awk keeps float percentages safe)
        if [ -n "$ctx_size" ] && [ "$ctx_size" -gt 0 ] 2>/dev/null; then
            used_tok=$(awk -v s="$ctx_size" -v p="$used_pct" 'BEGIN{printf "%.0f", s*p/100000}')
            if [ "$ctx_size" -ge 1000000 ]; then
                size_disp=$(awk -v s="$ctx_size" 'BEGIN{printf "%gM", s/1000000}')
            else
                size_disp=$(awk -v s="$ctx_size" 'BEGIN{printf "%gk", s/1000}')
            fi
            ctx_part="${ctx_part}$(printf " ${DIM}%sk/%s${RESET}" "$used_tok" "$size_disp")"
        fi
    fi
fi

# --- Compaction detection ---
compact_part=""
if [ -n "$used_pct" ] && [ -n "$session_id" ]; then
    cache_file="/tmp/claude-ctx-${session_id}.txt"
    used_int=$(printf "%.0f" "$used_pct")
    if [ -f "$cache_file" ]; then
        prev_pct=$(cat "$cache_file" 2>/dev/null)
        if [ -n "$prev_pct" ] && [ "$prev_pct" -gt 0 ] 2>/dev/null; then
            drop=$((prev_pct - used_int))
            if [ "$drop" -ge 20 ]; then
                compact_part=$(printf "${MAUVE}⟳ compacted${RESET}")
            fi
        fi
    fi
    echo "$used_int" > "$cache_file"
fi

# --- Session cost ---
cost_part=""
if [ -n "$cost_usd" ] && [ "$cost_usd" != "0" ] && [ "$cost_usd" != "null" ]; then
    cost_fmt=$(printf "%.2f" "$cost_usd" 2>/dev/null || echo "$cost_usd")
    # Strip trailing zeros: 2.50 -> 2.5, 3.00 -> 3
    cost_fmt=$(echo "$cost_fmt" | sed 's/0*$//; s/\.$//')
    cost_part=$(printf "${PEACH}\$%s${RESET}" "$cost_fmt")
fi

# --- Session duration ---
dur_part=""
if [ -n "$duration_ms" ] && [ "$duration_ms" -gt 0 ] 2>/dev/null; then
    dur_s=$((duration_ms / 1000))
    if [ "$dur_s" -ge 3600 ]; then
        dur_disp="$((dur_s / 3600))h$(((dur_s % 3600) / 60))m"
    elif [ "$dur_s" -ge 60 ]; then
        dur_disp="$((dur_s / 60))m"
    else
        dur_disp="${dur_s}s"
    fi
    dur_part=$(printf "${SUBTEXT}⏱%s${RESET}" "$dur_disp")
fi

# --- Rate limits (5h + 7d) with progress bars ---
# resets_at is Unix epoch seconds; BSD date -r, GNU date -d @
fmt_reset() {
    local epoch="$1" out="" today target fmt='+%-I:%M%p'
    [ -z "$epoch" ] && return
    # Include the date when the reset isn't today (7d windows are usually days out)
    today=$(date '+%Y-%m-%d' 2>/dev/null)
    target=$(date -r "$epoch" '+%Y-%m-%d' 2>/dev/null) || target=$(date -d "@$epoch" '+%Y-%m-%d' 2>/dev/null)
    [ -n "$target" ] && [ "$target" != "$today" ] && fmt='+%b %-d %-I:%M%p'
    out=$(date -r "$epoch" "$fmt" 2>/dev/null) || out=$(date -d "@$epoch" "$fmt" 2>/dev/null)
    printf '%s' "$out" | tr '[:upper:]' '[:lower:]' | tr -d '.'
}

build_rate() {
    local label="$1" pct_raw="$2" epoch="$3"
    [ -z "$pct_raw" ] && return
    local pct
    pct=$(printf "%.0f" "$pct_raw" 2>/dev/null) || return
    [ "$pct" -lt 0 ] && pct=0
    [ "$pct" -gt 100 ] && pct=100
    local filled=$((pct / 10)) empty=$((10 - pct / 10)) i
    local filled_str="" empty_str=""
    for ((i = 0; i < filled; i++)); do filled_str+="█"; done
    for ((i = 0; i < empty; i++)); do empty_str+="░"; done
    local color="$GREEN"
    [ "$pct" -ge 50 ] && color="$YELLOW"
    [ "$pct" -ge 80 ] && color="$BOLD_RED"
    local reset_display
    reset_display=$(fmt_reset "$epoch")
    # Filled run in the zone color, empty run muted — otherwise 3% looks like 100%
    if [ -n "$reset_display" ]; then
        printf "${SUBTEXT}%s${RESET}${color}%s${RESET}${DIM}${OVERLAY}%s${RESET} ${color}%3d%%${RESET}${DIM} ⟳%s${RESET}" \
            "$label" "$filled_str" "$empty_str" "$pct" "$reset_display"
    else
        printf "${SUBTEXT}%s${RESET}${color}%s${RESET}${DIM}${OVERLAY}%s${RESET} ${color}%3d%%${RESET}" \
            "$label" "$filled_str" "$empty_str" "$pct"
    fi
}

rate5_part=$(build_rate "5h:" "$rl5_pct" "$rl5_reset")
rate7_part=$(build_rate "7d:" "$rl7_pct" "$rl7_reset")

# --- Clickable PR link (OSC8, Ghostty/iTerm2/WezTerm) ---
pr_part=""
if [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        # Get remote URL and construct PR search link
        remote_url=$(git -C "$cwd" --no-optional-locks remote get-url origin 2>/dev/null)
        if [ -n "$remote_url" ]; then
            # Normalize to https URL
            repo_path=$(echo "$remote_url" | sed -E 's|^git@github\.com:|https://github.com/|; s|\.git$||; s|^https?://github\.com/||')
            if [ -n "$repo_path" ]; then
                # Check for open PR on this branch (cached per session to avoid rate limits)
                pr_cache="/tmp/claude-pr-${session_id}-$(echo "$branch" | md5 2>/dev/null || echo "$branch" | md5sum 2>/dev/null | cut -d' ' -f1).txt"
                pr_url=""
                if [ -f "$pr_cache" ] && [ "$(find "$pr_cache" -mmin -5 2>/dev/null)" ]; then
                    pr_url=$(cat "$pr_cache" 2>/dev/null | tr -d '\n\r')
                elif command -v gh >/dev/null 2>&1; then
                    pr_url=$(gh pr view "$branch" --json url -q '.url' 2>/dev/null | tr -d '\n\r' || echo "")
                    echo "$pr_url" > "$pr_cache"
                fi
                if [ -n "$pr_url" ]; then
                    # OSC8 clickable link
                    pr_num=$(basename "$pr_url")
                    pr_part=$(printf "${SUBTEXT}PR:${RESET}\033]8;;%s\a${BLUE}#%s${RESET}\033]8;;\a" "$pr_url" "$pr_num")
                fi
            fi
        fi
    fi
fi

# --- Lines changed ---
lines_part=""
if [ -n "$lines_add" ] && [ "$lines_add" != "0" ] && [ "$lines_add" != "null" ]; then
    lines_part=$(printf "${GREEN}+%s${RESET}" "$lines_add")
fi
if [ -n "$lines_rm" ] && [ "$lines_rm" != "0" ] && [ "$lines_rm" != "null" ]; then
    if [ -n "$lines_part" ]; then
        lines_part=$(printf "%s ${RED}-%s${RESET}" "$lines_part" "$lines_rm")
    else
        lines_part=$(printf "${RED}-%s${RESET}" "$lines_rm")
    fi
fi

# --- Assemble ---
# Line 1: starship (dir, git branch/worktree/status, k8s, aws, ...)
# Line 2: Claude session info (model/context, cost, rate limit, PR, lines changed)
join_parts() {
    local sep="$1"; shift
    local out="" p
    for p in "$@"; do
        [ -z "$p" ] && continue
        [ -z "$out" ] && out="$p" || out="$out$sep$p"
    done
    printf '%s' "$out"
}

sep_pipe=" ${OVERLAY}|${RESET} "

line1=$(join_parts "  " "${starship_output:+$workspace_emoji $starship_output}" "$starship_right")
line2=$(join_parts "$sep_pipe" "$pr_part" "$model_part" "$ctx_part" "$compact_part" "$cost_part" "$dur_part" "$rate5_part" "$rate7_part" "$lines_part")

[ -n "$line1" ] && printf "%b\n" "$line1"
[ -n "$line2" ] && printf "%b\n" "$line2"
