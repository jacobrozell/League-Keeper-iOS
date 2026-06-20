#!/usr/bin/env python3
"""Simulator UI helpers for evidence screenshot capture (idb + simctl)."""

from __future__ import annotations

import json
import subprocess
import sys
import time
from pathlib import Path


def run(cmd: list[str], *, check: bool = True) -> subprocess.CompletedProcess[str]:
    return subprocess.run(cmd, check=check, capture_output=True, text=True)


def describe_all(udid: str) -> list[dict]:
    result = run(["idb", "ui", "describe-all", "--udid", udid])
    return json.loads(result.stdout)


def frame_center(frame: dict) -> tuple[float, float]:
    return frame["x"] + frame["width"] / 2, frame["y"] + frame["height"] / 2


def find_element(
    elements: list[dict],
    *,
    label: str | None = None,
    uid: str | None = None,
    type_name: str | None = None,
    contains: str | None = None,
) -> dict | None:
    for element in elements:
        if uid and element.get("AXUniqueId") == uid:
            return element
        ax_label = element.get("AXLabel") or ""
        if label and ax_label == label:
            return element
        if contains and contains.lower() in ax_label.lower():
            return element
        if type_name and element.get("type") == type_name:
            return element
    return None


def tap(udid: str, x: float, y: float) -> None:
    run(["idb", "ui", "tap", "--udid", udid, str(int(x)), str(int(y))])


def tap_element(udid: str, element: dict) -> None:
    x, y = frame_center(element["frame"])
    tap(udid, x, y)


def tap_label(udid: str, label: str, *, contains: bool = False) -> bool:
    elements = describe_all(udid)
    element = find_element(
        elements,
        label=None if contains else label,
        contains=label if contains else None,
    )
    if not element:
        return False
    tap_element(udid, element)
    return True


def tap_uid(udid: str, uid: str) -> bool:
    element = find_element(describe_all(udid), uid=uid)
    if not element:
        return False
    tap_element(udid, element)
    return True


def swipe(udid: str, x1: float, y1: float, x2: float, y2: float) -> None:
    run(
        [
            "idb",
            "ui",
            "swipe",
            "--udid",
            udid,
            str(int(x1)),
            str(int(y1)),
            str(int(x2)),
            str(int(y2)),
        ]
    )


def screenshot(udid: str, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    run(["xcrun", "simctl", "io", udid, "screenshot", str(path)])


def terminate(udid: str, bundle_id: str) -> None:
    run(["xcrun", "simctl", "terminate", udid, bundle_id], check=False)


def install(udid: str, app_path: Path) -> None:
    run(["xcrun", "simctl", "install", udid, str(app_path)])


def launch(udid: str, bundle_id: str, args: list[str]) -> None:
    cmd = ["xcrun", "simctl", "launch", "--terminate-running-process", udid, bundle_id, *args]
    run(cmd)


def activate_simulator() -> None:
    script = """
tell application "Simulator" to activate
delay 0.4
"""
    run(["osascript", "-e", script])


def send_rotate_left() -> None:
    script = """
tell application "System Events"
  tell process "Simulator"
    key code 123 using {command down}
  end tell
end tell
"""
    run(["osascript", "-e", script])


def root_frame(udid: str) -> dict | None:
    elements = describe_all(udid)
    if not elements:
        return None
    return max(elements, key=lambda element: element.get("frame", {}).get("width", 0) * element.get("frame", {}).get("height", 0)).get("frame")


def is_landscape(udid: str) -> bool:
    frame = root_frame(udid)
    if not frame:
        return False
    return frame.get("width", 0) > frame.get("height", 0)


def set_orientation(orientation: str) -> None:
    """Rotate the booted simulator to portrait or landscape."""
    target_landscape = orientation == "landscape"
    activate_simulator()
    time.sleep(0.5)

    udid = run(["xcrun", "simctl", "list", "devices", "booted", "-j"]).stdout
    try:
        booted = json.loads(udid).get("devices", {})
        booted_udids = [
            device["udid"]
            for devices in booted.values()
            for device in devices
            if device.get("state") == "Booted"
        ]
    except json.JSONDecodeError:
        booted_udids = []

    for _ in range(4):
        if not booted_udids:
            break
        if is_landscape(booted_udids[0]) == target_landscape:
            break
        send_rotate_left()
        time.sleep(0.9)

    time.sleep(0.8)


def audit_report(elements: list[dict]) -> dict:
    buttons = [e for e in elements if e.get("type") == "Button"]
    switches = [e for e in elements if e.get("type") in ("CheckBox", "Switch")]
    fields = [e for e in elements if e.get("type") == "TextField"]
    unlabeled_buttons = [
        e for e in buttons if not (e.get("AXLabel") or e.get("AXUniqueId"))
    ]
    return {
        "element_count": len(elements),
        "buttons": len(buttons),
        "switches": len(switches),
        "text_fields": len(fields),
        "unlabeled_buttons": [
            {"uid": e.get("AXUniqueId"), "label": e.get("AXLabel"), "frame": e.get("frame")}
            for e in unlabeled_buttons
        ],
        "interactive": [
            {
                "type": e.get("type"),
                "label": e.get("AXLabel"),
                "uid": e.get("AXUniqueId"),
                "enabled": e.get("enabled"),
                "frame": e.get("frame"),
            }
            for e in elements
            if e.get("type") in ("Button", "CheckBox", "TextField", "Switch")
            and (e.get("AXLabel") or e.get("AXUniqueId"))
        ],
    }


def save_audit(udid: str, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    elements = describe_all(udid)
    path.write_text(json.dumps(audit_report(elements), indent=2), encoding="utf-8")


def main() -> None:
    if len(sys.argv) < 2:
        print("usage: capture_sim_helpers.py <command> ...", file=sys.stderr)
        sys.exit(1)

    command = sys.argv[1]
    if command == "tap-label":
        ok = tap_label(sys.argv[2], sys.argv[3], contains="--contains" in sys.argv)
        sys.exit(0 if ok else 1)
    if command == "tap-uid":
        ok = tap_uid(sys.argv[2], sys.argv[3])
        sys.exit(0 if ok else 1)
    if command == "screenshot":
        screenshot(sys.argv[2], Path(sys.argv[3]))
    elif command == "audit":
        save_audit(sys.argv[2], Path(sys.argv[3]))
    elif command == "orient":
        set_orientation(sys.argv[2])
    else:
        print(f"unknown command: {command}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
