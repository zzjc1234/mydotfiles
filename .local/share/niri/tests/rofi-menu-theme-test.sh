#!/bin/sh
set -eu

theme=${ROFI_MENU_THEME:-${HOME}/.config/rofi/niri-menu.rasi}

fail() {
    printf 'not ok - %s\n' "$1" >&2
    exit 1
}

[ -s "$theme" ] || fail "rofi menu theme exists"

grep -Eq 'children:[[:space:]]*\[[[:space:]]*textbox-prompt-colon,[[:space:]]*entry[[:space:]]*\];' "$theme" \
    || fail "rofi menu inputbar contains text entry"
grep -Eq '^entry[[:space:]]*\{' "$theme" \
    || fail "rofi menu styles text entry"

printf 'ok - rofi-menu theme input behavior\n'
