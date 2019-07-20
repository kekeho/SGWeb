# Copyright (c) 2019 Hiroki Takemura (kekeho)
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT


from flask import Flask, render_template, request
import uuid
from subprocess import Popen, PIPE
import json


app = Flask(__name__)  # Flask app
app.config['SECRET_KEY'] = str(uuid.uuid4())


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/post_code/', methods=['POST'])
def post_code():
    print('get request: ', request)
    code = request.json['code']
    docker_command = [
        'docker', 'run',
        '-i',
        '--rm',
        '--net=none',
        '--memory=128m',
        '--pids-limit=1024',
        'sgweb_executer'
    ]
    
    p = Popen(docker_command, stdout=PIPE, stderr=PIPE, stdin=PIPE)
    stdout, stderr = map(lambda x: x.decode(), p.communicate(input=code.encode()))

    return json.dumps({'stdout': stdout, 'stderr': stderr})


if __name__ == "__main__":
    app.run(host='0.0.0.0')
