"""Simple analysis of web-access-logs.csv using only the standard library."""
import csv, sys
from collections import Counter

file = sys.argv[1] if len(sys.argv) > 1 else "web-access-logs.csv"
with open(file, newline="") as f:
    rows = list(csv.DictReader(f))

print(f"Total requests: {len(rows)}")
print("\nTop requested pages:")
for path, n in Counter(r["path"] for r in rows).most_common(5):
    print(f"  {path:<22} {n}")

s4 = sum(1 for r in rows if r["status"].startswith("4"))
s5 = sum(1 for r in rows if r["status"].startswith("5"))
print(f"\n4xx errors: {s4}\n5xx errors: {s5}")

hours = Counter(r["timestamp"][11:13] for r in rows)
h, n = hours.most_common(1)[0]
print(f"\nPeak traffic hour: {h}:00 ({n} requests)")
print(f"Unique visitor IPs: {len({r['ip'] for r in rows})}")
