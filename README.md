# MySQL Backup Automation Suite

MySQL Database full backup automation with Bash script including Python script to sending email and crontab timer to schedule backup time.

---

## How it works

This system is an automatic data backup. It follows four simple steps to make sure your information is always safe:

1. The Container (Docker): 
	
	The MySQL database lives inside a Docker Container. This keeps it separate from the rest of your computer, making it clean and safe.

2. The Backup (mysqldump): 

	Every day, a bash backup script goes inside the box and takes a snapshot of all data in scope. Then, compresses this file to save storage space.

3. The Notification (Gmail): 
	
	After the backup is finished, the system call the python script. The script sends you a Gmail message immediately. It tells you "Success" if everything is okay, or "Failed" if there is a problem that needs your attention.

4. The Automation (Cron): 

	A built-in timer called "Cron" runs the entire process every day at a time you choose (like 3:00 AM).

---

## Setup Step

0. Prerequisites
* Operating System
	* WSL2: Recommend to use Ubantu
	* Linux
	* macOS
* Core Tools
	* Git: to clone the repository to local.
	* Docker & Docker Compose: to run MySQL database as container.
	* Python 3.x
* External Account
	* Gmail Account: that enabled Multi-Factor Authentication (MFA).
	* Gmail App Password: to use with the email sending script

1. Download the Project

<pre>
git clone https://github.com/lazy-cat-123/db-backup-automation.git

cd db-backup-automation
</pre>

2. Create enviroment variable

For safety, your passwords are not in the code. You must create a secret file called `.env`.

* What should have in `.env` file?

<pre>
CONTAINER_NAME="Your docker container name"
DB_ROOT_PASSWD="Your database root password"
DB_USERNAME="Your username in the database except root"
DB_PASSWD="The user's password"
DB_NAME="Database name"

GMAIL_SENDER="Sender's email address"
GMAIL_PASSWD="16 char of the Gmail SMTP"

GMAIL_RECEIVER="Receiver's email address"
</pre>

3. Prepare the Email sending system

The system uses Python to send emails. You need to set up a Virtual Environment by install the tools

Creting the environment: [Python venv setup](https://docs.python.org/3/library/venv.html)

Install package: dotenv

<pre>
pip install python-dotenv
</pre>

4. Configure the `db_backup.sh` variable paths

Before the backup script would works, you need to configure the paths to suits with your environment

<pre>
BACKUP_DIR="/your-project-directory-path/backup"

PYTHON_VENV_ACTIVATE_PATH="/your-venv-path/bin/activate"                    PYTHON_EXEC_PATH="/your-venv-path/bin/python3"                              PYTHON_NOTIF_SCRIPT_PATH="/your-project-directory-path/send_notif.py"
</pre>

5. Set the Daily timer

Finally, tell your computer to run the backup every day.

Open the timer settings: `crontab -e`

The contab configuration:
<pre>
0 21 * * * /path-to-db-backup-automation/db_backup.sh >    > /path-todb-back
up-automation/cron_output.log 2>&1
</pre>

The configuration will auto-execute `db_backup.sh` at 21:00 everyday and collect the output to `cront_out.log` file.
