import re
import os
from collections import defaultdict

LOG_FILE = "backend_server.log"

def parse_logs():
    events = defaultdict(list)
    log_path = os.path.join(os.path.dirname(__file__), LOG_FILE)
    
    if not os.path.exists(log_path):
        print(f"File {LOG_FILE} not found at {log_path}.")
        return

    try:
        with open(log_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            if not lines:
                 print(f"The log file {LOG_FILE} is empty.")
                 return

            for line in lines:
                match = re.search(r"AUDIT\[(.*?)\]: (.*)", line)
                if match:
                    event_type = match.group(1)
                    details = match.group(2)
                    # Extract timestamp if available (assuming standard python logging format)
                    # Format: 2023-10-27 10:00:00,123 - logger - INFO - message
                    timestamp = line.split(' - ')[0] if ' - ' in line else "Unknown Time"
                    events[event_type].append(f"[{timestamp}] {details}")
    except Exception as e:
        print(f"Error reading log file: {e}")
        return

    if not events:
        print("No audit events found in the log.")
        return

    print(f"\n{'='*40}")
    print(f" EVENT LOG ANALYSIS")
    print(f"{'='*40}")
    
    for event_type, logs in events.items():
        print(f"\n>>> EVENT TYPE: {event_type} ({len(logs)} entries)")
        for log in logs:
            print(f"  {log}")
    print(f"\n{'='*40}\n")

if __name__ == "__main__":
    parse_logs()
