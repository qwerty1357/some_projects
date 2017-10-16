function add_file_modal() {
    var button = document.getElementById('btn_modal_files');
    var div = document.getElementById('modal_window_files');
    if (div.style.display != 'none') {
        div.style.display = 'none';
    } else {
        div.style.display = 'block';
    }
}

function close_modal() {
    var button = document.getElementById('modal_close');
    var div = document.getElementById('modal_window_files');
    if (div.style.display != 'none') {
        div.style.display = 'none';
    } else {
        div.style.display = 'block';
    }
}
