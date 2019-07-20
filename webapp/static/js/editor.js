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


function post_shell_code(value) {
    let stdout = document.getElementById('exec-stdout');
    let stderr = document.getElementById('exec-stderr');
    let system_msg = document.getElementById('system-message');

    system_msg.innerText = '[System message]: executing...';
    let system_msg_clean_flag = false;

    axios.post('/post_code', {
        code: value
    })
    .then(function(response) {
        stdout.innerText = response.data.stdout;
        stderr.innerText = response.data.stderr;
    })
    .catch(function(error) {
        system_msg.innerText = error;
        system_msg_clean_flag = true;
    });

    if (!system_msg_clean_flag) {
        system_msg.innerText = '';
    }
}


var run_button = document.getElementById('run_button');
run_button.onclick = function() {
    let value = editor.getValue();
    post_shell_code(value);
};
