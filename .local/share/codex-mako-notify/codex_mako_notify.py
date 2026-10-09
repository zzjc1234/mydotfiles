#!/usr/bin/env python3
from __future__ import annotations

from contextlib import contextmanager
from dataclasses import dataclass
import fcntl
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time
from typing import Any, Iterator
import uuid


STATE_DIR = Path.home() / ".local" / "state" / "codex-mako-notify"
LOG_FILE = STATE_DIR / "notify.log"
TARGET_FILE = STATE_DIR / "targets.json"  # Kept for notifications sent before the queue.
QUEUE_FILE = STATE_DIR / "queue.json"
QUEUE_LOCK_FILE = STATE_DIR / "queue.lock"
STALE_AFTER_SECONDS = 60
CENTER_WINDOW_TITLE = "codex-notification-center"
CENTER_THEME = str(Path.home() / ".config" / "rofi" / "codex-notification-center.rasi")
WAYBAR_SIGNAL = 8
TARGET_ENV_KEYS = {
    "DBUS_SESSION_BUS_ADDRESS",
    "DISPLAY",
    "HERDR_ENV",
    "HERDR_PANE_ID",
    "HERDR_SESSION",
    "HERDR_SOCKET_PATH",
    "HERDR_TAB_ID",
    "HERDR_WORKSPACE_ID",
    "PATH",
    "WAYLAND_DISPLAY",
    "XDG_CURRENT_DESKTOP",
    "XDG_RUNTIME_DIR",
    "XDG_SESSION_TYPE",
}


@dataclass(frozen=True)
class Notification:
    title: str
    body: str
    urgency: str = "normal"


def ensure_state_dir() -> None:
    STATE_DIR.mkdir(parents=True, exist_ok=True, mode=0o700)
    try:
        STATE_DIR.chmod(0o700)
    except OSError:
        pass


def log(message: str) -> None:
    try:
        ensure_state_dir()
        with LOG_FILE.open("a", encoding="utf-8") as handle:
            handle.write(message.rstrip() + "\n")
    except OSError:
        pass


def read_payload(argv: list[str], stdin_data: str) -> dict[str, Any]:
    raw = ""
    if len(argv) > 1 and argv[1].strip():
        raw = argv[1].strip()
    elif stdin_data.strip():
        raw = stdin_data.strip()

    if not raw:
        return {"type": "message", "message": "Codex 有新状态"}

    try:
        payload = json.loads(raw)
    except json.JSONDecodeError:
        return {"type": "message", "message": raw}

    if isinstance(payload, dict):
        return payload
    return {"type": "message", "message": raw}


def shorten(text: str, limit: int = 900) -> str:
    text = " ".join(text.split()) if "\n" not in text else text.strip()
    if len(text) <= limit:
        return text
    return text[: limit - 1].rstrip() + "..."


def build_notification(payload: dict[str, Any]) -> Notification:
    event_type = str(payload.get("type") or "message")
    cwd = str(payload.get("cwd") or "").strip()

    if event_type == "agent-turn-complete":
        title = "Codex 完成"
        message = str(payload.get("last-assistant-message") or "任务完成")
        urgency = "normal"
    elif "approval" in event_type or "permission" in event_type:
        title = "Codex 等待确认"
        message = str(
            payload.get("message")
            or payload.get("reason")
            or payload.get("tool")
            or "需要你处理一个确认请求"
        )
        urgency = "critical"
    else:
        title = "Codex"
        message = str(payload.get("message") or event_type)
        urgency = "normal"

    body_parts = [part for part in (cwd, message.strip()) if part]
    body = shorten("\n".join(body_parts) or "Codex 有新状态")
    return Notification(title=title, body=body, urgency=urgency)


def build_notify_send_args(notification: Notification) -> list[str]:
    return [
        "notify-send",
        "-p",
        "-a",
        "Codex",
        "-u",
        notification.urgency,
        notification.title,
        notification.body,
    ]


def extract_target_env(env: dict[str, str]) -> dict[str, str]:
    target = {key: value for key, value in env.items() if key in TARGET_ENV_KEYS}
    for key, value in env.items():
        if key.startswith("KITTY_"):
            target[key] = value
    return target


def read_targets() -> dict[str, dict[str, str]]:
    try:
        data = json.loads(TARGET_FILE.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}
    if not isinstance(data, dict):
        return {}
    return {str(key): value for key, value in data.items() if isinstance(value, dict)}


def load_target(notification_id: str | None) -> dict[str, str]:
    targets = read_targets()
    if notification_id and notification_id in targets:
        return targets[notification_id]
    return targets.get("last", {})


def command_path(name: str, env: dict[str, str]) -> str:
    found = shutil.which(name, path=env.get("PATH"))
    if found:
        return found
    local = Path.home() / ".local" / "bin" / name
    if local.exists():
        return str(local)
    return name


def panel_direction(source: dict[str, Any], target: dict[str, Any]) -> str | None:
    source_rect = source.get("rect", {})
    target_rect = target.get("rect", {})
    source_x = source_rect.get("x", 0) + source_rect.get("width", 0) / 2
    source_y = source_rect.get("y", 0) + source_rect.get("height", 0) / 2
    target_x = target_rect.get("x", 0) + target_rect.get("width", 0) / 2
    target_y = target_rect.get("y", 0) + target_rect.get("height", 0) / 2
    if abs(target_x - source_x) >= abs(target_y - source_y) and target_x != source_x:
        return "right" if target_x > source_x else "left"
    if target_y != source_y:
        return "down" if target_y > source_y else "up"
    return None


def focus_codex(env: dict[str, str] | None = None) -> None:
    env = env or os.environ
    tab_id = env.get("HERDR_TAB_ID")
    if not tab_id:
        log("HERDR_TAB_ID is missing; cannot focus Codex")
        return
    herdr = command_path("herdr", env)
    result = subprocess.run(
        [herdr, "tab", "focus", tab_id],
        env=env,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    if result.returncode != 0:
        log(f"failed to focus Herdr tab {tab_id}")
        return

    panel_id = env.get("HERDR_PANE_ID")
    if not panel_id:
        return
    result = subprocess.run([herdr, "pane", "layout", "--pane", panel_id], env=env, text=True, capture_output=True, check=False)
    try:
        layout = json.loads(result.stdout)["result"]["layout"]
        panels = {panel["pane_id"]: panel for panel in layout["panes"]}
        focused = panels[layout["focused_pane_id"]]
        target = panels[panel_id]
    except (KeyError, TypeError, json.JSONDecodeError):
        log(f"failed to find Herdr panel {panel_id}")
        return
    direction = panel_direction(focused, target)
    if direction:
        subprocess.run([herdr, "pane", "focus", "--pane", focused["pane_id"], "--direction", direction], env=env, check=False)


def prompt_for_reply(env: dict[str, str] | None = None) -> str:
    env = env or os.environ
    rofi = shutil.which("rofi", path=env.get("PATH")) or str(Path.home() / ".local" / "bin" / "rofi")
    if rofi:
        result = subprocess.run(
            [rofi, "-dmenu", "-p", "Codex"],
            input="",
            env=env,
            text=True,
            capture_output=True,
            check=False,
        )
        return result.stdout.strip()

    fuzzel = shutil.which("fuzzel", path=env.get("PATH"))
    if fuzzel:
        result = subprocess.run(
            [fuzzel, "--dmenu", "--prompt", "Codex> "],
            input="",
            env=env,
            text=True,
            capture_output=True,
            check=False,
        )
        return result.stdout.strip()

    zenity = shutil.which("zenity", path=env.get("PATH"))
    if zenity:
        result = subprocess.run(
            [zenity, "--entry", "--title", "Codex", "--text", "Reply to Codex"],
            env=env,
            text=True,
            capture_output=True,
            check=False,
        )
        return result.stdout.strip()

    log("No input launcher found: rofi, fuzzel, or zenity is required for replies")
    return ""


def send_reply_to_codex(reply: str, env: dict[str, str] | None = None) -> None:
    env = env or os.environ
    pane_id = env.get("HERDR_PANE_ID")
    if not pane_id:
        log("HERDR_PANE_ID is missing; cannot send reply")
        return

    focus_codex(env)
    herdr = command_path("herdr", env)
    subprocess.run([herdr, "pane", "send-text", pane_id, reply], env=env, check=False)
    subprocess.run([herdr, "pane", "send-keys", pane_id, "Enter"], env=env, check=False)


def empty_queue() -> dict[str, Any]:
    return {"version": 1, "active": None, "items": []}


def normalize_queue(raw: Any) -> dict[str, Any]:
    if not isinstance(raw, dict):
        return empty_queue()

    items: list[dict[str, Any]] = []
    for raw_item in raw.get("items", []):
        if not isinstance(raw_item, dict) or not raw_item.get("token"):
            continue
        item = {
            "token": str(raw_item["token"]),
            "created_at": raw_item.get("created_at", time.time()),
            "title": str(raw_item.get("title") or "Codex"),
            "body": str(raw_item.get("body") or "Codex 有新状态"),
            "urgency": str(raw_item.get("urgency") or "normal"),
            "target": raw_item.get("target") if isinstance(raw_item.get("target"), dict) else {},
        }
        if raw_item.get("mako_id"):
            item["mako_id"] = str(raw_item["mako_id"])
        items.append(item)

    active = str(raw.get("active") or "")
    if active not in {item["token"] for item in items}:
        active = items[0]["token"] if items else None
    return {"version": 1, "active": active, "items": items}


def read_queue() -> dict[str, Any]:
    try:
        return normalize_queue(json.loads(QUEUE_FILE.read_text(encoding="utf-8")))
    except (OSError, json.JSONDecodeError):
        return empty_queue()


def write_queue(queue: dict[str, Any]) -> None:
    ensure_state_dir()
    temporary = QUEUE_FILE.with_name(f"{QUEUE_FILE.name}.{os.getpid()}.tmp")
    temporary.write_text(json.dumps(queue, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    temporary.chmod(0o600)
    temporary.replace(QUEUE_FILE)


@contextmanager
def queue_lock() -> Iterator[None]:
    ensure_state_dir()
    descriptor = os.open(QUEUE_LOCK_FILE, os.O_CREAT | os.O_RDWR, 0o600)
    try:
        fcntl.flock(descriptor, fcntl.LOCK_EX)
        yield
    finally:
        fcntl.flock(descriptor, fcntl.LOCK_UN)
        os.close(descriptor)


def find_item(queue: dict[str, Any], token: str | None) -> dict[str, Any] | None:
    if not token:
        return None
    return next((item for item in queue["items"] if item["token"] == token), None)


def send_notification(notification: Notification) -> str | None:
    try:
        result = subprocess.run(
            build_notify_send_args(notification),
            text=True,
            capture_output=True,
            check=False,
        )
    except OSError as exc:
        log(f"notify-send failed: {exc}")
        return None

    notification_id = result.stdout.strip()
    if result.stderr.strip():
        log(result.stderr.strip())
    if not notification_id:
        log("notify-send did not return a notification ID")
        return None
    return notification_id


def refresh_waybar() -> None:
    try:
        subprocess.run(
            ["pkill", f"-RTMIN+{WAYBAR_SIGNAL}", "waybar"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )
    except OSError:
        pass


def queue_notification(notification: Notification, env: dict[str, str] | None = None) -> str:
    item = {
        "token": uuid.uuid4().hex,
        "created_at": time.time(),
        "title": notification.title,
        "body": notification.body,
        "urgency": notification.urgency,
        "target": extract_target_env(env or os.environ),
    }
    with queue_lock():
        queue = read_queue()
        queue["items"].append(item)
        write_queue(queue)
        notification_id = send_notification(notification)
        if notification_id:
            item["mako_id"] = notification_id
        write_queue(queue)
    refresh_waybar()
    return item["token"]


def queue_snapshot() -> list[dict[str, Any]]:
    with queue_lock():
        return read_queue()["items"]


def item_for_mako_id(notification_id: str | None) -> dict[str, Any] | None:
    if not notification_id:
        return None
    with queue_lock():
        queue = read_queue()
        return next((item for item in queue["items"] if item.get("mako_id") == notification_id), None)


def dismiss_mako(notification_id: str | None) -> None:
    if notification_id:
        subprocess.run(
            ["makoctl", "dismiss", "--no-history", "-n", notification_id],
            text=True,
            capture_output=True,
            check=False,
        )


def current_mako_notification_id() -> str | None:
    result = subprocess.run(
        ["makoctl", "list"],
        text=True,
        capture_output=True,
        check=False,
    )
    for line in result.stdout.splitlines():
        if line.startswith("Notification "):
            notification_id = line.removeprefix("Notification ").partition(":")[0]
            return notification_id or None
    return None


def acknowledge_token(token: str, *, focus: bool) -> bool:
    with queue_lock():
        queue = read_queue()
        item = find_item(queue, token)
        if item is None:
            return False

        was_active = queue["active"] == token
        queue["items"] = [candidate for candidate in queue["items"] if candidate["token"] != token]
        if was_active:
            queue["active"] = queue["items"][0]["token"] if queue["items"] else None
        write_queue(queue)

    dismiss_mako(item.get("mako_id"))
    refresh_waybar()
    if focus:
        focus_codex(item["target"])
    return True


def clear_queue() -> int:
    with queue_lock():
        items = read_queue()["items"]
        write_queue(empty_queue())

    for item in items:
        dismiss_mako(item.get("mako_id"))
    refresh_waybar()
    return len(items)


def acknowledge_mako(notification_id: str | None, *, focus: bool) -> bool:
    item = item_for_mako_id(notification_id)
    if item:
        return acknowledge_token(item["token"], focus=focus)

    # Notifications created by the old script still have their target in targets.json.
    if focus:
        focus_codex(load_target(notification_id))
    dismiss_mako(notification_id)
    return False


def format_age(item: dict[str, Any], now: float | None = None) -> str:
    try:
        seconds = max(0, int((now or time.time()) - float(item["created_at"])))
    except (TypeError, ValueError):
        return "刚刚"
    if seconds < 60:
        return "刚刚"
    if seconds < 3600:
        return f"{seconds // 60} 分钟"
    if seconds < 86400:
        return f"{seconds // 3600} 小时"
    return f"{seconds // 86400} 天"


def status_payload(now: float | None = None) -> dict[str, str]:
    now = now or time.time()
    items = queue_snapshot()
    overdue = []
    for item in items:
        try:
            if now - float(item["created_at"]) >= STALE_AFTER_SECONDS:
                overdue.append(item)
        except (TypeError, ValueError):
            overdue.append(item)

    if not overdue:
        tooltip = "Codex：没有待确认任务" if not items else f"Codex：{len(items)} 条待确认（未满 {STALE_AFTER_SECONDS} 秒）"
        return {"text": f"󰚩 {len(items)}", "tooltip": tooltip, "class": "idle" if not items else "waiting"}

    preview = [
        f"• {format_age(item, now)}：{item['title']} — {shorten(' '.join(item['body'].split()), 180)}"
        for item in overdue[:5]
    ]
    tooltip = f"Codex：{len(overdue)} 条等待确认超过 {STALE_AFTER_SECONDS} 秒"
    if len(items) != len(overdue):
        tooltip += f"（共 {len(items)} 条）"
    return {"text": f"󰚩 {len(items)}", "tooltip": "\n".join([tooltip, *preview]), "class": "pending"}


def open_center() -> int:
    items = queue_snapshot()
    if not items:
        return 0

    rofi = shutil.which("rofi") or str(Path.home() / ".local" / "bin" / "rofi")
    rows = []
    tokens = []
    for item in items:
        summary = shorten(" ".join(item["body"].split()), 220)
        rows.append(f"{format_age(item)}  {item['title']} — {summary}")
        tokens.append(item["token"])
    result = subprocess.run(
        [
            rofi,
            "-theme",
            CENTER_THEME,
            "-dmenu",
            "-i",
            "-no-custom",
            "-only-match",
            "-p",
            "Codex 待确认",
            "-window-title",
            CENTER_WINDOW_TITLE,
            "-mesg",
            "Enter：确认；Alt+G：跳转至来源面板；Ctrl+Shift+Delete：清除全部；Esc：保留",
            "-kb-custom-1",
            "Control+Shift+Delete",
            "-kb-custom-2",
            "Alt+g",
            "-l",
            "8",
            "-format",
            "i",
        ],
        input="\n".join(rows) + "\n",
        text=True,
        capture_output=True,
        check=False,
    )
    if getattr(result, "returncode", 0) == 10:
        clear_queue()
        return 0
    try:
        token = tokens[int(result.stdout.strip())]
    except (IndexError, ValueError):
        return 0
    if result.returncode == 11:
        item = find_item({"items": items}, token)
        if item:
            focus_codex(item["target"])
        return 0
    acknowledge_token(token, focus=False)
    return 0


def handle_action(action: str, notification_id: str | None = None) -> None:
    if action in {"invoke-current", "dismiss-current"}:
        current_id = current_mako_notification_id()
        current_item = item_for_mako_id(current_id)
        if current_item:
            acknowledge_token(current_item["token"], focus=action == "invoke-current")
        elif action == "invoke-current":
            subprocess.run(["makoctl", "invoke"], check=False)
        else:
            subprocess.run(["makoctl", "dismiss"], check=False)
        return
    if action in {"default", "0", "focus"}:
        acknowledge_mako(notification_id, focus=True)
        return
    if action in {"acknowledge", "dismiss"}:
        acknowledge_mako(notification_id, focus=False)
        return
    if action != "reply":
        return

    item = item_for_mako_id(notification_id)
    target_env = os.environ.copy()
    target_env.update(item["target"] if item else load_target(notification_id))
    reply = prompt_for_reply(target_env)
    if not reply:
        return
    send_reply_to_codex(reply, target_env)
    if item:
        acknowledge_token(item["token"], focus=False)
    else:
        dismiss_mako(notification_id)


def run_worker(raw_payload: str) -> int:
    payload = read_payload(["codex-mako-notify", raw_payload], "")
    queue_notification(build_notification(payload))
    return 0


def start_worker(payload: dict[str, Any]) -> None:
    raw_payload = json.dumps(payload, ensure_ascii=False)
    subprocess.Popen(
        [sys.executable, __file__, "--worker", raw_payload],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True,
        close_fds=True,
    )


def main(argv: list[str] | None = None) -> int:
    argv = list(argv or sys.argv)
    if len(argv) > 2 and argv[1] == "--worker":
        return run_worker(argv[2])
    if len(argv) > 2 and argv[1] == "--action":
        handle_action(argv[2], argv[3] if len(argv) > 3 else None)
        return 0
    if len(argv) > 1 and argv[1] == "--center":
        if len(argv) > 2 and argv[2] == "--status":
            print(json.dumps(status_payload(), ensure_ascii=False))
            return 0
        return open_center()

    stdin_data = ""
    if not sys.stdin.isatty():
        stdin_data = sys.stdin.read()
    payload = read_payload(argv, stdin_data)
    try:
        start_worker(payload)
    except OSError as exc:
        log(f"failed to start notification worker: {exc}")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
