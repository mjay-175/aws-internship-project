"""Generate a synthetic web-access-logs.csv (sample dataset for the project)."""
import csv, random
from datetime import datetime, timedelta

random.seed(42)
paths = [("/index.html", 40), ("/health", 20), ("/about.html", 10), ("/login", 8),
         ("/static/style.css", 12), ("/missing-page", 5), ("/admin", 3), ("/api/data", 2)]
status_by_path = {"/missing-page": [404], "/admin": [403, 404], "/api/data": [500, 200], "/login": [200, 302, 401]}
agents = ["Mozilla/5.0", "curl/8.5.0", "Chrome/124.0", "Safari/17.0", "python-requests/2.31"]
ips = [f"203.0.113.{i}" for i in random.sample(range(1, 255), 40)]
start = datetime(2026, 7, 20, 8, 0, 0)

rows = []
for _ in range(500):
    ts = start + timedelta(seconds=random.randint(0, 12 * 3600))
    path = random.choices([p for p, _ in paths], weights=[w for _, w in paths])[0]
    status = random.choice(status_by_path.get(path, [200, 200, 200, 304]))
    rows.append([ts.strftime("%Y-%m-%d %H:%M:%S"), random.choice(ips), "GET", path,
                 status, random.randint(200, 6000), random.choice(agents)])
rows.sort()
with open("data/web-access-logs.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["timestamp", "ip", "method", "path", "status", "bytes", "user_agent"])
    w.writerows(rows)
print(len(rows), "rows written")
