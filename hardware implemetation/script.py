import serial
import time
from selenium import webdriver
from selenium.webdriver.common.by import By

# Set your COM port and NFC details
SERIAL_PORT = "COM9"  # Adjust your port
BAUD_RATE = 9600
LOGIN_UID = "2E3F1A7D"  # Replace with your actual NFC UID

# Website login details
URL = "https://aumscn.amrita.edu/cas/login?service=https%3A%2F%2Faumscn.amrita.edu%2Faums%2FJsp%2FCore_Common%2Findex.jsp%3Ftask%3Doff"
USERNAME = "ch.en.u4cys22039"
PASSWORD = "PrasannaNR@22"

try:
    ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
    print(f"Listening on {SERIAL_PORT} for NFC scans...")

    while True:
        if ser.in_waiting > 0:
            data = ser.readline().decode('utf-8').strip()

            if data.startswith("UID:"):
                uid = data[4:].strip()
                print(f"Scanned UID: {uid}")

                if uid == LOGIN_UID:
                    print("✅ Authorized NFC card detected! Logging in...")

                    # Initialize Selenium WebDriver for Firefox
                    driver = webdriver.Firefox()  # Ensure geckodriver is installed and in PATH
                    driver.get(URL)

                    # Perform login
                    username_field = driver.find_element(By.NAME, "username")
                    password_field = driver.find_element(By.NAME, "password")
                    login_button = driver.find_element(By.NAME, "submit")

                    username_field.send_keys(USERNAME)
                    password_field.send_keys(PASSWORD)
                    login_button.click()

                    print("✅ Login successful!")
                else:
                    print("🚫 Unauthorized NFC card")

except serial.SerialException as e:
    print(f"❌ Serial Error: {e}")
except Exception as e:
    print(f"❌ Error: {e}")
except KeyboardInterrupt:
    print("\nExiting...")
