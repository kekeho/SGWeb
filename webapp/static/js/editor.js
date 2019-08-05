// Copyright (c) 2019 Hiroki Takemura (kekeho)
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

// monaco editor
var editor = null;
require.config({
    paths: {'vs': 'https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.17.1/min/vs'}
});
require(['vs/editor/editor.main'], function() {
    editor = monaco.editor.create(document.getElementById('editor'), {
        language: 'shell',
        theme: 'vs-dark',
        minimap: { enabled: false }
    });
});


function clean_msg(msg_elements) {
    msg_elements.forEach(e => {
        e.innerText = '';
    });
}


function images_insert(images_list) {
    let image_row = document.getElementById('image_row');
    images_list.forEach(b64image => {
        let img = document.createElement('img');
        img.setAttribute('src', 'data:image/*;base64,' + b64image);

        let col = document.createElement('div');
        col.classList.add('col-6');
        col.appendChild(img);

        image_row.appendChild(col);
    });
}


function post_shell_code(value) {
    let stdout = document.getElementById('exec-stdout');
    let stderr = document.getElementById('exec-stderr');
    let system_msg = document.getElementById('system-message');
    let image_row = document.getElementById('image_row');

    clean_msg([stdout, stderr, system_msg, image_row]);

    system_msg.innerText = '[System message]: executing...';

    axios.post('/post_code/', {
        code: value
    })
    .then(function(response) {
        stdout.innerText = response.data.stdout;
        stderr.innerText = response.data.stderr;
        system_msg.innerText = response.data.sysmsg;
        images_insert(response.data.images);
    })
    .catch(function(error) {
        system_msg.innerText = error;
    });
}

const MAX_SAVE_ATTEMPTS = 10;

function add_recent_attempt(attempt) {
    let attempts = localStorage.getItem("attempts");
    if (attempts === null) {
        attempts = [attempt];
    }
    else {
        attempts = JSON.parse(attempts);
        attempts.unshift(attempt);
        while (attempts.length >= MAX_SAVE_ATTEMPTS) {
            attempts.pop();
        }
    }
    localStorage.setItem("attempts", JSON.stringify(attempts));
}

function update_attempts() {
    // remove all attempt dom elements
    let recents = document.getElementById("recents");
    while (recents.firstChild) {
        recents.removeChild(recents.firstChild);
    }

    // get recent attempts
    let attempts = localStorage.getItem("attempts");
    if (attempts === null) {
        attempts = [];
    }
    else {
        attempts = JSON.parse(attempts);
    }

    // add attempts
    for (let attempt of attempts) {
        let li = document.createElement("li");

        li.innerText = attempt;
        li.classList.add("recent");
        li.addEventListener("click", function(e) {
            editor.setValue(e.target.innerText);
        })
        recents.appendChild(li);
    }
}

document.getElementById("rm_button").addEventListener("click", function() {
    localStorage.removeItem("attempts");
    update_attempts();
});


var run_button = document.getElementById('run_button');
run_button.onclick = function() {
    let value = editor.getValue();
    post_shell_code(value);
    add_recent_attempt(value);
    update_attempts();
};

var tweet_button = document.getElementById('tweet_button');
tweet_button.onclick = function() {
    let value = editor.getValue();
    window.open("https://twitter.com/intent/tweet?text="+ encodeURIComponent(editor.getValue()) + "&hashtags=" + encodeURIComponent("シェル芸"))
};
