import smtplib
import sys
from email.message import EmailMessage

import os
from dotenv import load_dotenv

load_dotenv()

def send_email(subject, body):
    # --- Configuration ---
    SENDER_EMAIL = os.getenv("GMAIL_SENDER")
    SENDER_PASSWORD = os.getenv("GMAIL_PASSWD")
    RECEIVER_EMAIL = os.getenv("GMAIL_RECEIVER")

    msg = EmailMessage()
    msg.set_content(body)
    msg['Subject'] = subject
    msg['From'] = SENDER_EMAIL
    msg['To'] = RECEIVER_EMAIL

    try:
        with smtplib.SMTP_SSL('smtp.gmail.com', 465) as smtp:
            smtp.login(SENDER_EMAIL, SENDER_PASSWORD)
            smtp.send_message(msg)
        print("Email sent successfully!")
    except Exception as e:
        print(f"Failed to send email: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 2:
        send_email(sys.argv[1], sys.argv[2])
