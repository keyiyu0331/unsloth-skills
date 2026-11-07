import re

logs = [
    '192.168.1.10 - - [06/Nov/2026:10:15:32 +0000] "GET /api/models HTTP/1.1" 200 5123',
    '10.0.0.4 - alice [06/Nov/2026:10:15:40 +0000] "POST /api/inference/chat HTTP/1.1" 200 88211',
    '172.16.5.2 - - [06/Nov/2026:10:16:02 +0000] "GET /favicon.ico HTTP/1.1" 404 0',
    '10.0.0.4 - alice [06/Nov/2026:10:16:10 +0000] "DELETE /api/skills/old-skill HTTP/1.1" 204 0',
    '# comment line that must not match',
    'malformed line without a request'
]

# The regex pattern
# ^(\d{1,3}(?:\.\d{1,3}){3})  -> IP Address
# \s-\s([^\s]+)                -> The user (either '-' or a name)
# \s\[(.*?)\]                  -> The timestamp
# \s"(.*?)\s(.*?)HTTP.*?"      -> Method and Path
# \s(\d{3})                    -> Status Code
regex = r'^(\d{1,3}(?:\.\d{1,3}){3})\s-\s([^\s]+)\s\[(.*?)\]\s"(.*?)\s(.*?)\sHTTP.*?"\s(\d{3})\s\d+$'

print(f"{'IP':<15} | {'User':<8} | {'Timestamp':<25} | {'Method':<8} | {'Path':<30} | {'Status'}")
print("-" * 100)

for line in logs:
    match = re.match(regex, line)
    if match:
        groups = match.groups()
        print(f"{groups[0]:<15} | {groups[1]:<8} | {groups[2]:<25} | {groups[3]:<8} | {groups[4]:<30} | {groups[5]}")
    else:
        print(f"No match: {line}")
