# Copyright (c) 2019 Hiroki Takemura (kekeho)
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT


from flask import Flask, render_template, request
import redis
import uuid


app = Flask(__name__)  # Flask app
app.config['SECRET_KEY'] = str(uuid.uuid4())

redis_client = redis.Redis(host='redis')


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/post_code/', methods=['POST'])
def post_code():
    print('get request: ', request)
    code = request.json['code']
    redis_client.lpush('task', code)
    return code


if __name__ == "__main__":
    app.run(host='0.0.0.0')
