import os
import subprocess
import sys
import glob
import base64
import json

with sys.stdin as f:
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

with subprocess.Popen(['bash', '-c', shellscript_filename], stdout=subprocess.PIPE, stderr=subprocess.PIPE) as p:
    stdout, stderr = map(lambda x: x.decode(), p.communicate())

generated_images = [x for x in glob.glob('/images/*') if x.split('.')[-1] in ['jpg', 'JPG', 'png', 'PNG', 'gif', 'GIF']]
# encode base64
encoded = []
for img_filename in generated_images:
    with open(img_filename, 'rb') as f:
        content = f.read()
        encoded.append(base64.b64encode(content))

resp = {'stdout': stdout, 'stderr': stderr, 'images': [x.decode() for x in encoded]}
resp_json = json.dumps(resp)

print(resp_json)
