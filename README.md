# jobsearch for Homebrew (closed test)

`jobsearch` is a job search assistant. It finds job postings, scores how well each one fits you, and keeps track of them. The app is in a closed test: to install it, you need a download key from Rowena. More about the app: [job-search-agent-preview](https://github.com/rutgoff/job-search-agent-preview).

## What you need

- A Mac (Apple silicon or Intel) or a Linux computer.
- Your download key from Rowena: 32 letters, digits, `-` or `_`.
- About 10 minutes and 2 GB of free disk space.

## Install

1. Open the Terminal app.
2. If you do not have Homebrew, install it first. Copy this line into Terminal, push Return, and do what it tells you:

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. Run these 4 commands, 1 at a time:

   ```bash
   brew tap rutgoff/jobsearch-agent
   brew trust rutgoff/jobsearch-agent
   brew jobsearch-key
   brew install rutgoff/jobsearch-agent/jobsearch
   ```

   - `brew trust` lets Homebrew use this tap.
   - The full name `rutgoff/jobsearch-agent/jobsearch` makes sure that Homebrew installs this app, not another formula with the same short name.
   - `brew jobsearch-key` asks for your key. Paste the key and push Return. The key does not show on the screen.

4. Check the install: `jobsearch version` shows the version.

Then set up the app with the guide that Rowena sends you.

## Update

```bash
brew upgrade rutgoff/jobsearch-agent/jobsearch
```

## Remove

```bash
brew uninstall rutgoff/jobsearch-agent/jobsearch
```

Your settings and data stay in `~/.config/jobsearch` and `~/.local/share/jobsearch`. At the end of the test, also delete your download key:

```bash
rm ~/.config/jobsearch/download-key
```

## Problems

| You see | Do this |
|---|---|
| `No download key. Ask Rowena for your key, then run: brew jobsearch-key` | Run `brew jobsearch-key` and paste your key. |
| `Your download key was refused. Ask Rowena for a new key.` | If you got the key less than 1 minute ago, wait 1 minute and run the install again: a new key needs up to 1 minute to work. If it still fails, ask Rowena for a new key. Then run `brew jobsearch-key` again. |
| `Refusing to load ... from untrusted tap rutgoff/jobsearch-agent` | Run `brew trust rutgoff/jobsearch-agent`. |
| `That is not a download key.` | Copy the full key again: 32 characters, no spaces. |
| Another error | Send Rowena the last 20 lines of the Terminal output. Do not send your key. |

## Your key

- Your key is for you only. Do not share it.
- `brew jobsearch-key` keeps it in `~/.config/jobsearch/download-key`. Only your user can read that file.
- The key goes only to `software.utgoff.org`, in a request header over HTTPS.
