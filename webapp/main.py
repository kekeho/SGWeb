# Copyright (c) 2019 Hiroki Takemura (kekeho)
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT


from flask import Flask, render_template, request
import uuid
from subprocess import Popen, PIPE, TimeoutExpired, run
import requests
import json
import os


app = Flask(__name__)  # Flask app
app.config['SECRET_KEY'] = str(uuid.uuid4())


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/post_code/', methods=['POST'])
def post_code():
    docker_command = [
        'docker', 'run',
        '-i',
        '--rm',
        '--net=none',
        '--memory=128m',
        '--pids-limit=1024',
        'sgweb_executer',
    ]

    p = Popen(docker_command, stdout=PIPE, stderr=PIPE, stdin=PIPE)
    try:
        code = request.json['code']
        resp_json, sysmsg = map(lambda x: x.decode(), p.communicate(input=code.encode(), timeout=20.0))
        print('sysmessage', sysmsg)
        resp = json.loads(resp_json)
        stdout = resp['stdout']
        stderr = resp['stderr']
        images = resp['images']
    except json.JSONDecodeError:
        stdout, stderr, sysmsg = ('', '', '')
        images = []
    except TimeoutExpired:
        stdout, stderr, sysmsg = ('', '', '[Error]: Timeout (over 20s)')
        images = []
    p.kill()

    return json.dumps({'stdout': stdout, 'stderr': stderr, 'sysmsg': sysmsg, 'images': images})


@app.route('/dockerhub_webhook/', methods=["POST"])
def build_executer():
    """When get webhook from dockerhub, build executer container"""
    repo_name = request.json['repository']['repo_name']
    tag = request.json['push_data']['tag']

    if not (repo_name == 'theoldmoon0602/shellgeibot' and tag == 'latest'):
        return
    
    # validate webhook callback
    callback_url = request.json['callback_url']
    validate_result = requests.post(callback_url, json=request.json)

    if validate_result.json()['status'] != 'success':
        return

    # build executer container
    run(['docker', 'pull', repo_name])  # pull kernel image
    compose_filename = os.path.abspath(os.path.join(os.path.dirname(__file__), '../'))
    run(['docker-compose', '-f', compose_filename, 'build', 'executer'])


if __name__ == "__main__":
    app.run(host='0.0.0.0')
