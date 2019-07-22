import os
import subprocess

with open(0) as f:
    code = f.read()

if code == '':
    exit(0)

shellscript_filename = '/task.sh'

# create script file
with open(shellscript_filename, 'w') as f:
    f.write(code)

# chmod +x
current_permit = os.stat(shellscript_filename)
os.chmod(shellscript_filename, 555)

subprocess.run(['bash', '-c', shellscript_filename])
