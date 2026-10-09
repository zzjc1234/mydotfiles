#!/bin/sh
set -eu

script=${NIRI_HOTKEYS_SCRIPT:-${HOME}/.local/bin/niri-hotkeys}
data=${NIRI_HOTKEYS_DATA:-${HOME}/.local/share/niri/hotkeys.tsv}
theme=${NIRI_HOTKEYS_THEME:-${HOME}/.config/rofi/niri-hotkeys.rasi}

fail() {
    printf 'not ok - %s\n' "$1" >&2
    exit 1
}

assert_contains() {
    haystack=$1
    needle=$2

    case "$haystack" in
        *"$needle"*) ;;
        *) fail "expected output to contain: $needle" ;;
    esac
}

assert_not_contains() {
    haystack=$1
    needle=$2

    case "$haystack" in
        *"$needle"*) fail "expected output not to contain: $needle" ;;
        *) ;;
    esac
}

assert_no_key() {
    key=$1

    if awk -F '\t' -v key="$key" '$1 !~ /^#/ && $2 == key { found=1 } END { exit found ? 0 : 1 }' "$data"; then
        fail "expected TSV not to contain key: $key"
    fi
}

[ -x "$script" ] || fail "script is executable"
[ -s "$data" ] || fail "hotkey data exists"
[ -s "$theme" ] || fail "hotkey list theme exists"

grep -Eq 'columns:[[:space:]]*1;' "$theme" || fail "theme uses one list column"
grep -Eq 'lines:[[:space:]]*(1[2-9]|[2-9][0-9]);' "$theme" || fail "theme shows a long list"
grep -Eq 'dynamic:[[:space:]]*true;' "$theme" || fail "theme keeps dynamic filtering enabled"
grep -Eq 'children:[[:space:]]*\[[[:space:]]*textbox-prompt-colon,[[:space:]]*entry[[:space:]]*\];' "$theme" || fail "theme inputbar contains text entry"
grep -Eq '^entry[[:space:]]*\{' "$theme" || fail "theme styles text entry"

list=$("$script" --list)

assert_contains "$list" "Help"
assert_contains "$list" "Mod+Shift+Slash"
assert_contains "$list" "Search Hotkeys"
assert_contains "$list" "Apps"
assert_contains "$list" "Super+Space"
assert_contains "$list" "Open rofi menu"
assert_contains "$list" "Windows"
assert_contains "$list" "Super+H"
assert_contains "$list" "Focus Left"
assert_contains "$list" "niri msg action show-hotkey-overlay"
assert_no_key "Mod+T"
assert_no_key "Super+Return"

count=$(printf '%s\n' "$list" | sed '/^[[:space:]]*$/d' | wc -l)
[ "$count" -ge 20 ] || fail "lists at least 20 hotkeys"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

cat > "$tmpdir/rofi-capture" <<'EOF'
#!/bin/sh
printf '%s\n' "$@" > "$NIRI_HOTKEYS_CAPTURE"
cat > "$NIRI_HOTKEYS_STDIN"
exit 0
EOF
chmod +x "$tmpdir/rofi-capture"

NIRI_HOTKEYS_ROFI="$tmpdir/rofi-capture" \
NIRI_HOTKEYS_CAPTURE="$tmpdir/args" \
NIRI_HOTKEYS_STDIN="$tmpdir/stdin" \
    "$script"

args=$(cat "$tmpdir/args")
assert_contains "$args" "-theme"
assert_contains "$args" "$theme"

menu_rows=$(cat "$tmpdir/stdin")
assert_contains "$menu_rows" "Help"
assert_contains "$menu_rows" "Mod+Shift+Slash"
assert_contains "$menu_rows" "Search Hotkeys"
assert_contains "$menu_rows" "Apps"
assert_contains "$menu_rows" "Super+Space"
assert_contains "$menu_rows" "Open rofi menu"

case "$menu_rows" in
    *"	niri msg action show-hotkey-overlay"*)
        fail "visible menu hides command column"
        ;;
esac

first_row=$(printf '%s\n' "$menu_rows" | sed -n '1p')
case "$first_row" in
    Help*"Mod+Shift+Slash"*"Search Hotkeys"*) ;;
    *) fail "visible menu starts with categorized Help row" ;;
esac

printf 'ok - niri-hotkeys list behavior\n'
