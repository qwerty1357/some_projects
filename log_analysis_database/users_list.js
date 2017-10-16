function add_user_modal() {
    var button = document.getElementById('btn_modal_users');
    var div = document.getElementById('modal_window_users');
    if (div.style.display != 'none') {
        div.style.display = 'none';
    } else {
        div.style.display = 'block';
    }
}


function close_modal() {
    var button = document.getElementById('modal_close');
    var div = document.getElementById('modal_window_users');
    if (div.style.display != 'none') {
        div.style.display = 'none';
    } else {
        div.style.display = 'block';
    }
}

function jsAlert() {
    alert("Ops! Login already in database.");
}
