require.config({
    paths: {'vs': 'https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.17.1/min/vs'}
});

require(['vs/editor/editor.main'], function() {
    var editor = monaco.editor.create(document.getElementById('editor'), {
        language: 'shell',
        theme: 'vs-dark',
        minimap: { enabled: false }
    });
});
