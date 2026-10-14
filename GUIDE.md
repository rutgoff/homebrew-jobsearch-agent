# jobsearch tester guide

jobsearch helps you with a job search on your own computer. It collects job postings, ranks them against your resume, and writes a tailored resume and a cover letter for each job that you choose.

This guide is for the closed test. Do the steps in order. The first setup takes about 30 minutes.

## What you need

You need these things to use jobsearch:

1. A Mac (Apple silicon or Intel) or a Linux computer. Windows is not part of this test. Linux in WSL 2 can work, but nobody has tested it yet.
2. [Homebrew](https://brew.sh). Homebrew installs jobsearch and the Python that it needs.
3. A download key from Rowena: 32 letters, digits, `-` or `_`. She sends it to you in a private message. The key is for you only.
4. A Claude plan that includes Claude Code, for example Pro, Max, or Team. jobsearch uses your plan through Claude Code, with your own sign-in. Do not share your sign-in.
5. Your resume as a PDF, a DOCX, or a text file (`.txt` or `.md`).
6. git, pandoc, and Google Chrome (on Linux, Chromium also works). git keeps your resume files. pandoc and Chrome make the PDF of your resume. Step 3 shows how to install them.
7. About 30 minutes and 4 GB of free disk space for the first setup. On an Intel Mac, allow 20 minutes more: Homebrew can build Python from source there.

These items are optional:

- A personal Gmail address that gets LinkedIn job alerts. jobsearch reads the alerts with an app password, with read access only. Your Google account needs 2-Step Verification for the app password.
- Adzuna API keys: an App ID and an API key. [Sign up for free](https://developer.adzuna.com/). With the keys, jobsearch can also search the Adzuna job API.
- An [Exa](https://exa.ai/) API key. With the key, jobsearch looks for the employer's posting by itself, with at most 40 Exa searches a day. Without the key, you add the link or the text of the posting yourself.

## 1. Install jobsearch

Do the steps in [README.md](README.md). Then check the install:

```bash
jobsearch version
```

## 2. Sign in to Claude

jobsearch sends its requests through Claude Code, with your own Claude account. Do this step even if you use the Claude Desktop app: a sign-in to Claude Desktop does not sign in Claude Code.

1. Install Claude Code:

   ```bash
   brew install --cask claude-code
   ```

   On Linux, install Claude Code as [Anthropic's setup page](https://code.claude.com/docs/en/setup) says.

2. Start Claude Code, sign in, and stop it:

   ```bash
   claude
   ```

   In Claude Code, type `/login` and sign in with your Claude account. Then type `/exit`.

3. Make sure that no API key is set. This command must show `not set`:

   ```bash
   echo "${ANTHROPIC_API_KEY:-not set}"
   ```

Run jobsearch in a normal terminal window, not inside Claude Code. jobsearch never asks for your Claude password or token. Claude Code keeps your sign-in on your computer.

## 3. Make your resume repo

jobsearch keeps your resume as small text files in a folder (a "resume-as-code" repo). From these files, it makes a tailored copy for each job.

1. Install the tools for the PDF:

   ```bash
   brew install pandoc
   ```

   Also install [Google Chrome](https://www.google.com/chrome/). On a Mac, git comes with `xcode-select --install`. The next command checks all the tools and tells you what is missing.

2. Import your resume:

   ```bash
   jobsearch resume start --from ~/Documents/My_Resume.pdf
   ```

   Use the path of your own resume file (`.pdf`, `.docx`, `.txt`, or `.md`).

3. Answer the questions (8 at most). They ask for facts that make the resume stronger, for example a number or a tool. Press Enter to skip a question. Type `stop` to end the questions.

4. Read the PDF. On a Mac, it opens by itself. Then answer the question "Does the resume look right?".

The folder is `~/Documents/Jobsearch/resume-as-code`. To change your resume later, edit a file in its `src` folder, then run `./build.sh general` in the folder. The `README.md` in the folder shows the layout and the rules.

## 4. Get jobs into jobsearch

### A job link

Add a job from the link of the employer's posting:

```bash
jobsearch track add https://jobs.example.com/platform-engineer
```

Use the employer's link, not a linkedin.com link. You can also press `+` in the job list (step 5).

### LinkedIn job alerts in your Gmail

jobsearch can read the LinkedIn job alerts in a personal Gmail mailbox. It only reads: it never sends, moves, or deletes mail.

1. In LinkedIn, make job alerts, and send them to your Gmail address.
2. Connect the mailbox:

   ```bash
   jobsearch gmail connect
   ```

   The command shows 3 steps: turn on 2-Step Verification for your Google account, make an app password named "jobsearch" at [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords), and paste its 16 letters. jobsearch tests the login before it keeps the app password in your Keychain.

3. Read the alerts now:

   ```bash
   jobsearch linkedin sync
   ```

4. Optional: read them every 3 hours:

   ```bash
   jobsearch linkedin schedule install
   ```

   `jobsearch linkedin schedule status` shows the last run. `jobsearch linkedin schedule uninstall` stops it.

A Google Workspace (company) mailbox cannot use an app password.

### The posting text of an alert job

A tailored resume needs the text of the employer's posting. A LinkedIn alert gives only the title and the company. In the job list (step 5), select the job, then:

- press `u` and paste the link of the employer's posting (jobsearch reads that page), or
- press `e` and paste the text of the job description.

Optional: with an [Exa](https://exa.ai/) API key, jobsearch looks for the posting by itself after each LinkedIn sync and each search, with at most 40 Exa searches a day. Store the key. The command asks for the key and does not show it:

```bash
jobsearch secrets set EXA_API_KEY
```

### Optional: an Adzuna search

jobsearch can also search the Adzuna job API.

1. Sign up for free at [developer.adzuna.com](https://developer.adzuna.com/). Get an App ID and an API key.
2. Store the 2 keys. Each command asks for 1 key and does not show it:

   ```bash
   jobsearch secrets set ADZUNA_APP_ID
   jobsearch secrets set ADZUNA_API_KEY
   ```

3. Run a search. The command asks what to search for:

   ```bash
   jobsearch search
   ```

   In the job list (step 5), `s` also starts a search.

A search also writes a report with a learning plan for your skill gaps, interview questions, and career advice. Adzuna gives only the start of each job description, so add the posting text as for an alert job (above).

## 5. Daily use

Open the job list:

```bash
jobsearch tui
```

| Key | What it does |
|---|---|
| `↑` `↓` | Select a job |
| `+` | Add a job |
| `u` | Add the link of the employer's posting |
| `e` | Paste the text of the job description |
| `a` | Score the selected job against your resume (Claude) |
| `p` | Mark the job: pursue |
| `x` | Mark the job: skip |
| `z` | Undo the last mark |
| `t` | Make a tailored resume for the job |
| `c` | Write a cover letter for the job |
| `v` | Open the PDF of the job's resume |
| `S` | Mark the application as sent |
| `/` | Find a job |
| `?` | Show all keys |
| `q` | Quit |

The same work from the command line, with the first characters of the job's ID:

```bash
jobsearch resume tailor a1b2c3d4
jobsearch cover-letter generate a1b2c3d4
```

## 6. Update jobsearch

Rowena tells you when a new version is out. Then run:

```bash
brew update && brew upgrade rutgoff/jobsearch-agent/jobsearch
```

## 7. Your data

- Your data stays on your computer:
  - the settings are in `~/.config/jobsearch/`;
  - the job data is in `~/.local/share/jobsearch/`;
  - your documents are in `~/Documents/Jobsearch/`.
- When jobsearch uses Claude, it sends your resume text, the job text, and your answers to your own Claude plan. No other service gets them.
- With the optional keys, jobsearch sends your search words to Adzuna. Exa gets only the job title and the company.
- Rowena gets nothing from jobsearch. She sees only what you send her.
- Your Gmail app password is in your Mac's Keychain (on Linux: the Secret Service).
- Your download key is only for downloads of jobsearch. Do not share it.

## 8. Send feedback

Reply to your invite email. Tell Rowena:

1. what you did (the command or the key);
2. what you expected;
3. what happened, with the output.

Remove personal data from the output first.

## 9. When something goes wrong

| You see | Do this |
|---|---|
| `Not logged in · Please run /login` or `Claude Team plan check failed` | Do step 2 again. |
| `Install these tools first:` | Install the tools in the list (step 3). |
| `No text found in the file.` | Use a text copy of your resume, or save it as a PDF from your word processor. |
| `Gmail refused the app password.` | Make a new app password, then run `jobsearch gmail connect` again. |
| `No usable employer posting for this job.` | Add the posting with `u` or `e` in the job list (step 4). |
| An error in the install | See "Problems" in [README.md](README.md). |
| Anything else | Reply to your invite email with the output. |
