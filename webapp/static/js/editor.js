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


function post_shell_code(value) {
    let stdout = document.getElementById('exec-stdout');
    let stderr = document.getElementById('exec-stderr');
    let system_msg = document.getElementById('system-message');

    clean_msg([stdout, stderr, system_msg]);

    system_msg.innerText = '[System message]: executing...';

    axios.post('/post_code', {
        code: value
    })
    .then(function(response) {
        stdout.innerText = response.data.stdout;
        stderr.innerText = response.data.stderr;
        system_msg.innerText = response.data.sysmsg;
    })
    .catch(function(error) {
        system_msg.innerText = error;
    });
}


var run_button = document.getElementById('run_button');
run_button.onclick = function() {
    let value = editor.getValue();
    post_shell_code(value);
};
