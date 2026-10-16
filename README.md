# SDET UI tests

    python3 tools/main.py                  # whole UI suite, random right user only (wrong-user test skipped)
    python3 tools/main.py --id 19          # choose the right user (ids 1-30, Users.json)
    python3 tools/main.py --id 104         # also run the wrong-user test with user 104 (ids 101+, InvalidUsers.json)
    python3 tools/main.py --id 19 --id 104 # choose both
    python3 tools/main.py --test LoginTestUITests/CartUITests    # only some tests
    python3 tools/main.py --api-only       # API checks only

Each run: pick a right user (+ a wrong user only if you pass a wrong id) -> check with POST /auth/login -> run the UI tests
(login tests get the right user, `testLoginWithWrongUser` gets the wrong user)
-> `build/summary.md`, `build/xcodebuild.log`, `build/Result.xcresult`. Exit code 0 = all passed.
