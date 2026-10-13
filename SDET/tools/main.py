"""Run the whole UI suite with ONE right user (Users.json), checked through the API first.
The wrong-user test (negative login) only runs when you pass a wrong id (101+, InvalidUsers.json).

    python3 tools/main.py                     # random right user, wrong-user test skipped
    python3 tools/main.py --id 19             # choose the right user (ids 1-30)
    python3 tools/main.py --id 19 --id 104    # right user 19 + wrong user 104 (runs the negative test too)
    python3 tools/main.py --id 104            # wrong user 104 + a random right user
    python3 tools/main.py --test LoginTestUITests/CartUITests      # only some tests (repeatable)
    python3 tools/main.py --api-only          # API checks only, no simulator

Optional overrides: TEST_DEVICE, TEST_OS, BASE_URL
"""
import argparse
import json
import os
import random
import re
import shutil
import subprocess
import sys
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BUILD = ROOT / "build"

PROJECT = ROOT / "LoginTest/LoginTest.xcodeproj"
SCHEME = "LoginTest"
# What to run: Target, Target/Class or Target/Class/method (no parentheses).
# "LoginTestUITests" = every test in the UI test target.
UI_TESTS = ["LoginTestUITests"]
WRONG_USER_TEST = "LoginTestUITests/LoginUITests/testLoginWithWrongUser"   # skipped unless a wrong id is given
DEVICE = os.getenv("TEST_DEVICE", "iPhone 18 Pro")
OS_VERSION = os.getenv("TEST_OS", "27.0")
BASE_URL = os.getenv("BASE_URL", "https://dummyjson.com")


def pick_user(file_name, ids):
    """The user from `file_name` whose id is in `ids`; a random one if none of the ids belong to this file."""
    users = json.loads((ROOT / file_name).read_text())["users"]
    chosen = [u for u in users if u["id"] in ids]
    return chosen[0] if chosen else random.choice(users)


def wrong_user_if_asked(ids):
    """The wrong user only when an id from InvalidUsers.json was given, otherwise None."""
    users = json.loads((ROOT / "InvalidUsers.json").read_text())["users"]
    return next((u for u in users if u["id"] in ids), None)


def check_ids(ids):
    known = {u["id"] for f in ("Users.json", "InvalidUsers.json")
             for u in json.loads((ROOT / f).read_text())["users"]}
    unknown = [i for i in ids if i not in known]
    if unknown:
        sys.exit(f"Unknown user id(s) {unknown}. Right users: 1-30 (Users.json), wrong users: 101+ (InvalidUsers.json).")


def api_login(user):
    """POST /auth/login. Returns ("accepted" | "rejected" | "error", detail)."""
    req = urllib.request.Request(
        BASE_URL + "/auth/login",
        data=json.dumps({"username": user["username"], "password": user["password"]}).encode(),
        headers={"Content-Type": "application/json",
                 # Cloudflare rejects Python's default User-Agent with 403 / error 1010
                 "User-Agent": "Mozilla/5.0 (Macintosh) AppleWebKit/605.1.15 SDET-Tests/1.0"},
        method="POST")
    try:
        with urllib.request.urlopen(req, timeout=15) as r:
            body = json.loads(r.read())
        if body.get("accessToken") or body.get("token"):
            return "accepted", "token received"
        return "error", "no token in response"
    except urllib.error.HTTPError as e:
        detail = f"HTTP {e.code}: {e.read()[:120].decode(errors='replace')}"
        return ("rejected" if e.code in (400, 401) else "error"), detail   # 403 etc. = blocked, not a login answer
    except urllib.error.URLError as e:
        return "error", f"unreachable: {e.reason}"


def run_ui_tests(right, wrong, tests):
    """Returns (passed, summary_text). Reads the test counts from the xcodebuild log."""
    subprocess.run(["defaults", "write", "com.apple.iphonesimulator", "ConnectHardwareKeyboard", "-bool", "false"])
    bundle = BUILD / "Result.xcresult"
    shutil.rmtree(bundle, ignore_errors=True)  # xcodebuild will not overwrite
    cmd = ["xcodebuild", "test",
           "-project", str(PROJECT), "-scheme", SCHEME,
           "-destination", f"platform=iOS Simulator,name={DEVICE},OS={OS_VERSION}",
           "-resultBundlePath", str(bundle),
           "-parallel-testing-enabled", "NO"]
    for t in tests:
        cmd += ["-only-testing", t]
    if wrong is None:
        cmd += ["-skip-testing", WRONG_USER_TEST]
    wrong = wrong or {"username": "not-a-user", "password": "not-a-password"}   # unused when the test is skipped
    env = {**os.environ,   # xcodebuild passes TEST_RUNNER_<NAME> to the tests as <NAME>
           "TEST_RUNNER_LOGIN_USERNAME": right["username"],
           "TEST_RUNNER_LOGIN_PASSWORD": right["password"],
           "TEST_RUNNER_WRONG_USERNAME": wrong["username"],
           "TEST_RUNNER_WRONG_PASSWORD": wrong["password"],
           "TEST_RUNNER_BASE_URL": BASE_URL}
    log_file = BUILD / "xcodebuild.log"
    with open(log_file, "w") as log:
        ok = subprocess.run(cmd, env=env, stdout=log, stderr=subprocess.STDOUT).returncode == 0

    log = log_file.read_text(errors="replace")
    counts = re.findall(r"Executed (\d+) tests?, with (\d+) failures?", log)
    total, failures = (counts[-1] if counts else ("?", "?"))
    failed = sorted(set(re.findall(r"Test Case '-\[\S+ (\w+)\]' failed", log)))
    text = f"{total} tests, {failures} failed"
    if failed:
        text += " (" + ", ".join(failed) + ")"
    return ok, text


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--id", type=int, action="append", default=[],
                    help="user id: 1-30 = right user (Users.json), 101+ = wrong user (InvalidUsers.json); repeatable")
    ap.add_argument("--test", action="append", help="Target[/Class[/method]]; repeat for several")
    ap.add_argument("--api-only", action="store_true", help="skip the simulator")
    args = ap.parse_args()

    BUILD.mkdir(exist_ok=True)
    check_ids(args.id)
    right = pick_user("Users.json", args.id)             # random unless an id from Users.json was given
    wrong = wrong_user_if_asked(args.id)                 # None unless an id from InvalidUsers.json was given
    print(f"[right user] {right['username']} (id={right['id']})")
    if wrong:
        print(f"[wrong user] {wrong['username']} (id={wrong['id']}) - {wrong['reason']}")

    checks = []   # (label, expected, api result, passed, detail)
    pairs = [("right", right, "accepted")] + ([("wrong", wrong, "rejected")] if wrong else [])
    for label, user, expected in pairs:
        result, detail = api_login(user)
        checks.append((label, user, expected, result == expected, detail))
        print(f"[api] {label} user: login {result} (expected {expected}) -> {'PASS' if result == expected else 'FAIL'}: {detail}")

    ui_ok, ui_text = None, "skipped"
    if not args.api_only:
        ui_ok, ui_text = run_ui_tests(right, wrong, args.test or UI_TESTS)
        ui_text = ("PASS - " if ui_ok else "FAIL - ") + ui_text
        print(f"[ui] {ui_text}")

    rows = "".join(f"| {label} | {u['username']} (id={u['id']}) | {exp} | {'PASS' if ok else 'FAIL - ' + d} |\n"
                   for label, u, exp, ok, d in checks)
    (BUILD / "summary.md").write_text(
        "| User | Name | API should | API check |\n|---|---|---|---|\n" + rows +
        f"\nUI tests: {ui_text}  (details: build/xcodebuild.log, build/Result.xcresult)\n")
    return 0 if all(c[3] for c in checks) and ui_ok is not False else 1


if __name__ == "__main__":
    sys.exit(main())
