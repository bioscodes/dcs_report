## Deployment process

This project is developed in:

- `/home/konstantin/ghq/github.com/konscodes/dcs_report`

and deployed for cron to run from:

- `/opt/dcs_report`

The cron job is configured (via `crontab -l`) to run:

- `0 0 1 * * /opt/dcs_report/.venv/bin/python /opt/dcs_report/main.py`

The deployment process keeps these two directories in sync.

---

### 1. Preconditions

- Code in the dev repo is committed and tested as needed.
- `/opt/dcs_report` already exists and contains a clone of the repo.
- You can run commands as a user that has write access to `/opt/dcs_report`.

---

### 2. Deploying a new version

From the dev repo:

```bash
cd /home/konstantin/ghq/github.com/konscodes/dcs_report
bash ./deploy.sh
```

What `deploy.sh` does:

1. **Verifies** it is being executed from the expected dev path.
2. **Rsyncs** the working tree into `/opt/dcs_report`, excluding:
   - `.git`
   - `.venv`
   - `__pycache__`, `.mypy_cache`, `.pytest_cache`
   - `output`
3. **Ensures** a virtualenv exists at `/opt/dcs_report/.venv` (creates one if missing).
4. **Installs/updates dependencies** from `requirements.txt` into that virtualenv.

After this, cron will continue using:

- `/opt/dcs_report/.venv/bin/python /opt/dcs_report/main.py`

with the freshly deployed code.

---

### 3. Manual verification

After deploying, you can run the production copy manually:

```bash
/opt/dcs_report/.venv/bin/python /opt/dcs_report/main.py
```

Check:

- The generated CSV files in `/opt/dcs_report/output/`
- The log file `/opt/dcs_report/output/event.log` for the `Script started.` entry and any errors.

---

### 4. Notes

- If you ever change the production path or venv location, update:
  - `deploy.sh` (`PROD_DIR` and `VENV_DIR`)
  - The cron entry in `crontab -e`.
- The dev and prod repos both track the same remote:
  - `https://github.com/konscodes/dcs_report.git`

