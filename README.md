# Technical operator agent

This repository contains all the stuff to run a technical operator agent.

His role is to help me with my daily tasks, coding sessions and sysadmin operations.

Setup:
- Debian server
- Local LLM

## Local LLM inference

I run it on a local LLM setup with a RTX 3060 12G and llama.cpp for the inference.

Setup: [RTX-3060-12G-llama.cpp](https://github.com/t1t4nium/local-llm/tree/main/RTX-3060-12G-llama.cpp)

## Run it with Hermes Agent

I install Hermes Agent with a dedicated user `hermes` which doesn't have admin rights (eg. sudo).

### Prerequisites

Install required packages:

```bash
apt install -y build-essential curl gh git libffi-dev python3-dev wget
```

Setup `hermes` user:

```bash
useradd hermes
loginctl enable-linger hermes
```

### Install Hermes Agent

As `hermes` user:

```bash
wget https://hermes-agent.nousresearch.com/install.sh
bash install.sh --channel stable --non-interactive --skip-computer-use --verbose
rm -f install.sh
source ~/.bashrc
```

### Configuration

Apply agent settings.

As `hermes` user:

```bash
git clone https://github.com/t1t4nium/agent-technical-operator.git
cd agent-technical-operator
sh hermes-agent/config.sh
cp SOUL.md ~/.hermes/SOUL.md
```

### Gateway

Install, enable and start gateway service:

```bash
hermes gateway install --start-on-login --start-now
```

### Dashboard (optional)

**Only on a secure and trusted network behind a firewall.**

The first time you run the dashboard, you have to define the basic auth credentials:

```bash
hermes dashboard --host 0.0.0.0 --no-open
hermes dashboard --stop
```

Then, move the credentials to the `.env` file:

```bash
set +o history
hermes config set security.redact_secrets false
echo "HERMES_DASHBOARD_USER=$(hermes config get dashboard.basic_auth.username)" >> ~/.hermes/.env
HASH=$(hermes config get dashboard.basic_auth.password_hash)
SECRET=$(hermes config get dashboard.basic_auth.secret)
echo "HERMES_DASHBOARD_PASSWORD_HASH='${HASH}'" >> ~/.hermes/.env
echo "HERMES_DASHBOARD_SECRET='${SECRET}'" >> ~/.hermes/.env
unset HASH; unset SECRET
hermes config set security.redact_secrets true
hermes config set dashboard.basic_auth.username '${HERMES_DASHBOARD_USER}'
hermes config set dashboard.basic_auth.password_hash '${HERMES_DASHBOARD_PASSWORD_HASH}'
hermes config set dashboard.basic_auth.secret '${HERMES_DASHBOARD_SECRET}'
set -o history
```

Install, enable and start dashboard service:

```bash
cd agent-technical-operator
cp hermes-agent/hermes-dashboard.service ~/.config/systemd/user/
systemctl --user enable --now hermes-dashboard.service
```