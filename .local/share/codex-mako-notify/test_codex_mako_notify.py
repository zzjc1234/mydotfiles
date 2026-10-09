#!/usr/bin/env python3
import importlib.util
import json
from pathlib import Path
import sys
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch


MODULE_PATH = Path(__file__).with_name("codex_mako_notify.py")


def load_module():
    spec = importlib.util.spec_from_file_location("codex_mako_notify", MODULE_PATH)
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


class CodexMakoNotifyTests(unittest.TestCase):
    def setUp(self):
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.module = load_module()
        state_dir = Path(self.temporary_directory.name)
        self.module.STATE_DIR = state_dir
        self.module.LOG_FILE = state_dir / "notify.log"
        self.module.TARGET_FILE = state_dir / "targets.json"
        self.module.QUEUE_FILE = state_dir / "queue.json"
        self.module.QUEUE_LOCK_FILE = state_dir / "queue.lock"

    def tearDown(self):
        self.temporary_directory.cleanup()

    def test_agent_turn_complete_builds_mako_notification(self):
        payload = {
            "type": "agent-turn-complete",
            "cwd": "/home/example",
            "last-assistant-message": "ok",
        }

        notification = self.module.build_notification(payload)
        args = self.module.build_notify_send_args(notification)

        self.assertEqual(notification.title, "Codex 完成")
        self.assertIn("/home/example", notification.body)
        self.assertIn("ok", notification.body)
        self.assertIn("-p", args)
        self.assertNotIn("x-canonical-private-synchronous:codex", args)
        self.assertNotIn("-A", args)
        self.assertNotIn("--wait", args)

    def test_reads_json_payload_from_first_argument(self):
        raw = json.dumps({"type": "approval-requested", "cwd": "/tmp/project"})

        payload = self.module.read_payload(["codex-mako-notify", raw], "")

        self.assertEqual(payload["type"], "approval-requested")
        self.assertEqual(payload["cwd"], "/tmp/project")

    def test_extracts_target_environment_for_mako_actions(self):
        env = {
            "HERDR_PANE_ID": "w1:p4",
            "HERDR_TAB_ID": "w1:t4",
            "HERDR_SOCKET_PATH": "/tmp/herdr.sock",
            "PATH": "/bin",
        }

        target = self.module.extract_target_env(env)

        self.assertEqual(target["HERDR_PANE_ID"], "w1:p4")
        self.assertEqual(target["HERDR_TAB_ID"], "w1:t4")
        self.assertEqual(target["HERDR_SOCKET_PATH"], "/tmp/herdr.sock")
        self.assertEqual(target["PATH"], "/bin")

    def test_focus_codex_opens_the_notification_panel_without_a_workspace_fallback(self):
        calls = []
        layout = {
            "result": {
                "layout": {
                    "focused_pane_id": "w3:p7",
                    "panes": [
                        {"pane_id": "w3:p5", "rect": {"x": 0, "y": 0, "width": 100, "height": 20}},
                        {"pane_id": "w3:p7", "rect": {"x": 0, "y": 21, "width": 100, "height": 20}},
                    ],
                }
            }
        }

        def run(args, **kwargs):
            calls.append(args)
            if args[1:] == ["tab", "focus", "w3:t4"]:
                return SimpleNamespace(returncode=0, stdout="")
            if args[1:] == ["pane", "layout", "--pane", "w3:p5"]:
                return SimpleNamespace(returncode=0, stdout=json.dumps(layout))
            return SimpleNamespace(returncode=1, stdout="")

        with patch.object(self.module, "command_path", return_value="herdr"), patch.object(
            self.module.subprocess, "run", side_effect=run
        ):
            self.module.focus_codex({"HERDR_TAB_ID": "w3:t4", "HERDR_PANE_ID": "w3:p5"})

        self.assertEqual(
            calls,
            [
                ["herdr", "tab", "focus", "w3:t4"],
                ["herdr", "pane", "layout", "--pane", "w3:p5"],
                ["herdr", "pane", "focus", "--pane", "w3:p7", "--direction", "up"],
            ],
        )

    def test_each_queued_item_is_sent_to_mako_immediately(self):
        first = self.module.Notification("Codex 完成", "first")
        second = self.module.Notification("Codex 完成", "second")
        env = {"HERDR_TAB_ID": "1:1", "HERDR_PANE_ID": "1-1", "PATH": "/bin"}

        with patch.object(self.module, "send_notification", side_effect=["101", "102"]) as send, patch.object(
            self.module, "dismiss_mako"
        ), patch.object(self.module, "refresh_waybar") as refresh:
            first_token = self.module.queue_notification(first, env)
            self.module.queue_notification(second, env)
            self.assertEqual(send.call_count, 2)

            self.assertTrue(self.module.acknowledge_token(first_token, focus=False))

        queue = self.module.read_queue()
        self.assertEqual(send.call_count, 2)
        self.assertEqual(refresh.call_count, 3)
        self.assertEqual(queue["items"][0]["body"], "second")
        self.assertEqual(queue["items"][0]["mako_id"], "102")

    def test_refresh_waybar_uses_the_codex_module_signal(self):
        with patch.object(self.module.subprocess, "run") as run:
            self.module.refresh_waybar()

        self.assertEqual(run.call_args.args[0], ["pkill", "-RTMIN+8", "waybar"])

    def test_clear_queue_removes_only_queued_codex_notifications(self):
        queue = self.module.empty_queue()
        queue["items"] = [{"token": "one", "mako_id": "101"}, {"token": "two", "mako_id": "102"}]
        self.module.write_queue(queue)

        with patch.object(self.module, "dismiss_mako") as dismiss, patch.object(self.module, "refresh_waybar") as refresh:
            self.assertEqual(self.module.clear_queue(), 2)

        self.assertEqual(self.module.read_queue()["items"], [])
        self.assertEqual(dismiss.call_args_list[0].args, ("101",))
        self.assertEqual(dismiss.call_args_list[1].args, ("102",))
        refresh.assert_called_once()

    def test_status_shows_total_count_and_marks_old_items_as_pending(self):
        now = 1_000.0
        queue = self.module.empty_queue()
        queue["items"] = [
            {
                "token": "old",
                "created_at": now - self.module.STALE_AFTER_SECONDS,
                "title": "Codex 完成",
                "body": "old task",
                "urgency": "normal",
                "target": {},
            },
            {
                "token": "new",
                "created_at": now - 1,
                "title": "Codex 完成",
                "body": "new task",
                "urgency": "normal",
                "target": {},
            },
        ]
        queue["active"] = "old"
        self.module.write_queue(queue)

        status = self.module.status_payload(now)

        self.assertEqual(status["text"], "󰚩 2")
        self.assertEqual(status["class"], "pending")
        self.assertIn("old task", status["tooltip"])
        self.assertNotIn("new task", status["tooltip"])

    def test_status_shows_an_idle_icon_when_the_queue_is_empty(self):
        status = self.module.status_payload(1_000.0)

        self.assertEqual(status["text"], "󰚩 0")
        self.assertEqual(status["class"], "idle")

    def test_reads_the_same_current_notification_id_that_makoctl_uses(self):
        output = "Notification 42: Codex 完成\n  App name: Codex\nNotification 41: Other\n"

        with patch.object(self.module.subprocess, "run", return_value=SimpleNamespace(stdout=output)):
            notification_id = self.module.current_mako_notification_id()

        self.assertEqual(notification_id, "42")

    def test_message_center_uses_its_own_rofi_window_title(self):
        item = {
            "token": "item",
            "created_at": 1_000.0,
            "title": "Codex 完成",
            "body": "task",
            "urgency": "normal",
            "target": {},
        }
        with patch.object(self.module, "queue_snapshot", return_value=[item]), patch.object(
            self.module.shutil, "which", return_value="/usr/bin/rofi"
        ), patch.object(
            self.module.subprocess, "run", return_value=SimpleNamespace(stdout="")
        ) as run:
            self.module.open_center()

        args = run.call_args.args[0]
        self.assertEqual(args[args.index("-theme") + 1], self.module.CENTER_THEME)
        self.assertEqual(args[args.index("-window-title") + 1], self.module.CENTER_WINDOW_TITLE)

    def test_message_center_clears_queue_with_its_custom_shortcut(self):
        item = {"token": "item", "created_at": 1_000.0, "title": "Codex 完成", "body": "task", "urgency": "normal", "target": {}}
        with patch.object(self.module, "queue_snapshot", return_value=[item]), patch.object(
            self.module.shutil, "which", return_value="/usr/bin/rofi"
        ), patch.object(
            self.module.subprocess, "run", return_value=SimpleNamespace(returncode=10, stdout="")
        ) as run, patch.object(self.module, "clear_queue") as clear:
            self.module.open_center()

        args = run.call_args.args[0]
        self.assertEqual(args[args.index("-kb-custom-1") + 1], "Control+Shift+Delete")
        clear.assert_called_once()

    def test_message_center_confirmation_does_not_change_workspace(self):
        item = {"token": "item", "created_at": 1_000.0, "title": "Codex 完成", "body": "task", "urgency": "normal", "target": {}}
        with patch.object(self.module, "queue_snapshot", return_value=[item]), patch.object(
            self.module.shutil, "which", return_value="/usr/bin/rofi"
        ), patch.object(
            self.module.subprocess, "run", return_value=SimpleNamespace(returncode=0, stdout="0")
        ), patch.object(self.module, "acknowledge_token") as acknowledge:
            self.module.open_center()

        acknowledge.assert_called_once_with("item", focus=False)

    def test_message_center_jump_shortcut_keeps_the_message(self):
        item = {"token": "item", "created_at": 1_000.0, "title": "Codex 完成", "body": "task", "urgency": "normal", "target": {}}
        with patch.object(self.module, "queue_snapshot", return_value=[item]), patch.object(
            self.module.shutil, "which", return_value="/usr/bin/rofi"
        ), patch.object(
            self.module.subprocess, "run", return_value=SimpleNamespace(returncode=11, stdout="0")
        ) as run, patch.object(self.module, "focus_codex") as focus, patch.object(self.module, "acknowledge_token") as acknowledge:
            self.module.open_center()

        args = run.call_args.args[0]
        self.assertEqual(args[args.index("-kb-custom-2") + 1], "Alt+g")
        focus.assert_called_once_with({})
        acknowledge.assert_not_called()


if __name__ == "__main__":
    unittest.main()
