import csv
import random
from datetime import datetime, timedelta
import os

random.seed(42)

NUM_ROWS = 500
OUTPUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'data')
OUTPUT_FILE = os.path.join(OUTPUT_DIR, 'web-access-logs.csv')

# Ensure output directory exists
os.makedirs(OUTPUT_DIR, exist_ok=True)

IPS = [f"192.168.1.{random.randint(1, 255)}" for _ in range(15)] + \
      [f"10.0.0.{random.randint(1, 255)}" for _ in range(5)]
# Give some IPs higher weight
IP_WEIGHTS = [10, 8, 5, 5, 5] + [1] * 15

METHODS = ["GET", "POST", "HEAD"]
METHOD_WEIGHTS = [90, 8, 2]

PATHS_200 = ["/", "/index.html", "/health.html", "/style.css", "/about", "/contact", "/api/status", "/favicon.ico", "/images/logo.png", "/login", "/dashboard", "/admin"]
PATHS_404 = ["/nonexistent", "/old-page.html", "/api/v1/deleted"]

STATUS_CODES = [200, 304, 404, 500, 403]
STATUS_WEIGHTS = [75, 10, 10, 3, 2]

USER_AGENTS = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0",
    "curl/7.68.0",
    "Googlebot/2.1 (+http://www.google.com/bot.html)"
]

def generate_timestamp():
    # Last 7 days
    now = datetime.now()
    days_ago = random.randint(0, 7)
    
    # Weight towards business hours (8 AM to 6 PM)
    if random.random() < 0.7:
        hour = random.randint(8, 17)
    else:
        hour = random.randint(0, 23)
        
    minute = random.randint(0, 59)
    second = random.randint(0, 59)
    
    ts = now - timedelta(days=days_ago)
    ts = ts.replace(hour=hour, minute=minute, second=second)
    return ts.strftime("%Y-%m-%d %H:%M:%S")

with open(OUTPUT_FILE, 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(["timestamp", "ip", "method", "path", "status", "bytes", "user_agent"])
    
    for _ in range(NUM_ROWS):
        timestamp = generate_timestamp()
        ip = random.choices(IPS, weights=IP_WEIGHTS)[0]
        method = random.choices(METHODS, weights=METHOD_WEIGHTS)[0]
        status = random.choices(STATUS_CODES, weights=STATUS_WEIGHTS)[0]
        
        if status == 404:
            path = random.choice(PATHS_404)
            bytes_sent = random.randint(200, 500)
        elif status in [500, 403]:
            path = random.choice(PATHS_200)
            bytes_sent = random.randint(200, 1000)
        elif status == 304:
            path = random.choice(PATHS_200)
            bytes_sent = 0
        else:
            path = random.choice(PATHS_200)
            if path.endswith(".png"):
                bytes_sent = random.randint(10000, 50000)
            elif path.endswith(".css"):
                bytes_sent = random.randint(5000, 15000)
            else:
                bytes_sent = random.randint(1000, 8000)
                
        user_agent = random.choice(USER_AGENTS)
        
        writer.writerow([timestamp, ip, method, path, status, bytes_sent, user_agent])

print(f"Generated {NUM_ROWS} rows to {OUTPUT_FILE}")
