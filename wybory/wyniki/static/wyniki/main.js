function openModal(key, co_wybrano) {

    var x = document.getElementById("overlay");

    if (x.style.visibility != 'visible') {
        x.style.visibility = 'visible';

        var question
        if (key == "wojewodztwo") {
            question = "/wyniki/ajax/get_votes/?req=wojewodztwo&wojewodztwo=" + co_wybrano;
        } else if (key == "rodzaj") {
            question = "/wyniki/ajax/get_votes/?req=rodzaj&status=" + co_wybrano;
        } else if (key == "oddo") {
            question = "/wyniki/ajax/get_votes/?req=oddo&od=" + document.getElementById("od").value + '&do=' + document.getElementById("do").value;
        }

        var isLogged = document.getElementById("isAuthenticated");

        xhttp = new XMLHttpRequest();

        xhttp.addEventListener("load", function() {
            var questions;

            questions = JSON.parse(this.responseText)

            create_table(questions);

        });

        xhttp.open("GET", question);
        xhttp.send();

    }

}



function get_rodzaj_data() {
    //localStorage.clear();

    if (localStorage.getItem('rodzaj') === null) {

        refresh_rodzaj();

    } else {

        var questions = JSON.parse(localStorage.getItem('rodzaj'));

        create_key_table(questions['rodzaj'], 'rodzaje');

        refresh_rodzaj();
    }
}



function get_wojewodztwa_data() {


    if (localStorage.getItem('wojewodztwo') === null) {

        refresh_wojewodztwo();

    } else {

        var questions = JSON.parse(localStorage.getItem('wojewodztwo'));

        create_key_table(questions['wojewodztwa'], 'wojewodztwa');

        refresh_wojewodztwo();
    }

}



function refresh_rodzaj() {
    var question, questions;

    question = "/wyniki/rodzaj_list/";

    var xhttp = new XMLHttpRequest();

    xhttp.open("GET", question);

    xhttp.send();

    xhttp.addEventListener("load", function() {

        questions = JSON.parse(this.responseText);

        create_key_table(questions['rodzaj'], 'rodzaje');

        localStorage.setItem('rodzaj' , this.responseText);

    });
}



function refresh_wojewodztwo() {
    var question, questions;

    question = "/wyniki/wojewodztwa_list/";

    var xhttp = new XMLHttpRequest();

    xhttp.open("GET", question);

    xhttp.send();

    xhttp.addEventListener("load", function() {

        questions = JSON.parse(this.responseText);

        create_key_table(questions['wojewodztwa'], 'wojewodztwa');

        localStorage.setItem('wojewodztwo' , this.responseText);

    });
}



function create_key_table(questions, key) {

    var nazwa;
    if (key === 'wojewodztwa') {
        var el = document.getElementById("wojewodztwo-body");
        nazwa = 'wojewodztwo';
    } else {
        if (key === 'rodzaje') {
            var el = document.getElementById("rodzaj-body");
            nazwa = 'typ';
        }
    }

    for (i = el.children.length - 1; i >= 0; i--) {
        el.removeChild(el.children[i]);
    }


    var new_el, new_input, row, new_button, new_lu, new_li, new_h5, new_h6, new_prg, new_btn, x;
    for (i = 0; i < questions.length; ++i) {
        row = document.createElement('tr');

        new_btn = document.createElement('button');
        var v = questions[i][nazwa];
        if (nazwa === 'typ') {
            x = 'rodzaj';

        } else {
            x = nazwa;
        }
        new_btn.value = questions[i][nazwa];
        new_btn.innerHTML = questions[i][nazwa];
        new_btn.className = 'linkBtn';
        new_btn.type = 'button';
        new_btn.id = questions[i][nazwa];

        new_btn.addEventListener('click', function() {
            openModal(x, this.value);
        });

        new_el = document.createElement('td');
        new_el.appendChild(new_btn);

        row.appendChild(new_el);

        new_el = document.createElement('td');
        new_el.innerHTML = questions[i]['sum'];
        row.appendChild(new_el);

        new_el = document.createElement('td');
        new_el.innerHTML = questions[i]['result1'];
        row.appendChild(new_el);

        new_el = document.createElement('td');
        new_ul = document.createElement('ul');
        new_ul.className = 'skill-list';
        new_li = document.createElement('li');
        new_li.className = 'skill';
        new_h5 = document.createElement('h5');
        new_h5.innerHTML = questions[i]['pr1'] + ' %';
        new_h6 = document.createElement('h6');
        new_h6.innerHTML = questions[i]['pr2'] + ' %';
        new_prg = document.createElement('progress');
        new_prg.className = 'skill-1';
        new_prg.max = '100';
        new_prg.value = questions[i]['pr1'];

        new_li.appendChild(new_h5);
        new_li.appendChild(new_h6);
        new_li.appendChild(new_prg);
        new_ul.appendChild(new_li);
        new_el.appendChild(new_ul);
        row.appendChild(new_el);

        new_el = document.createElement('td');
        new_el.innerHTML = questions[i]['result2'];
        row.appendChild(new_el);
        el.appendChild(row);

    }

}



function create_table(questions) {

    var isLogged = document.getElementById("isAuthenticated");
    var el = document.getElementById("gmina-body");
    var modal_content = document.getElementById("modal_content");
    var gm_rm1 = document.getElementById('pierwszy');
    var gm_rm2= document.getElementById('drugi');
    var gm_rm3 = document.getElementById('trzeci');
    var gm_rm4 = document.getElementById('czwarty');
    if (gm_rm1 != null) {
        gm_rm1.parentNode.removeChild(gm_rm1);
        gm_rm2.parentNode.removeChild(gm_rm2);
        gm_rm3.parentNode.removeChild(gm_rm3);
        gm_rm4.parentNode.removeChild(gm_rm4);
    }

    var i;
    for (i = el.children.length - 1; i >= 0; i--) {
        el.removeChild(el.children[i]);
    }

    var new_el, new_input, row, new_button, new_lu, new_li, new_h5, new_h6, new_prg;
    form = document.getElementById("my-form");
    if (isLogged != null) {
        gmina_input = document.createElement('select');
        gmina_input.name = 'nazwa';
        gmina_input.id = 'pierwszy';
        gmina_input.className = 'slct';
        kandydat1_input = document.createElement('input');
        kandydat1_input.id = 'drugi';
        kandydat1_input.name = 'kandydat1';
        kandydat1_input.className = 'form-input';
        kandydat2_input = document.createElement('input');
        kandydat2_input.name = 'kandydat2';
        kandydat2_input.id = 'trzeci';
        kandydat2_input.className = 'form-input';
        submit_input = document.createElement('input');
        submit_input.id = 'czwarty';
        submit_input.value = 'aktualizuj';
        submit_input.className = 'login-btn';
        submit_input.type = 'button';

        submit_input.addEventListener('click', function() {
            form_post(document.getElementById("my-form"));
        });

    }


    for (i = 0; i < questions.length; ++i) {
        if (isLogged != null) {
            option = document.createElement('option');
            option.value = questions[i]['nazwa'];
            option.innerHTML = questions[i]['nazwa'];
            gmina_input.appendChild(option);
        }

        row = document.createElement('tr');

        new_el = document.createElement('td');
        new_el.innerHTML = questions[i]['nazwa'];
        row.appendChild(new_el);

        new_el = document.createElement('td');
        new_el.innerHTML = questions[i]['sum'];
        row.appendChild(new_el);

        new_el = document.createElement('td');
        new_el.innerHTML = questions[i]['result1'];
        new_el.id = questions[i]['nazwa'] + '1';
        row.appendChild(new_el);

        new_el = document.createElement('td');
        new_ul = document.createElement('ul');
        new_ul.className = 'skill-list';
        new_li = document.createElement('li');
        new_li.className = 'skill';
        new_h5 = document.createElement('h5');
        new_h5.innerHTML = questions[i]['pr1'] + ' %';
        new_h6 = document.createElement('h6');
        new_h6.innerHTML = questions[i]['pr2'] + ' %';
        new_prg = document.createElement('progress');
        new_prg.className = 'skill-1';
        new_prg.max = '100';
        new_prg.value = questions[i]['pr1'];

        new_li.appendChild(new_h5);
        new_li.appendChild(new_h6);
        new_li.appendChild(new_prg);
        new_ul.appendChild(new_li);
        new_el.appendChild(new_ul);
        row.appendChild(new_el);

        new_el = document.createElement('td');
        new_el.innerHTML = questions[i]['result2'];
        new_el.id = questions[i]['nazwa'] + '2';
        console.log(new_el.id);
        row.appendChild(new_el);
        el.appendChild(row);
    }

    if (isLogged != null) {
        form.appendChild(gmina_input);
        form.appendChild(kandydat1_input);
        form.appendChild(kandydat2_input);
        form.appendChild(submit_input);
    }

}



function form_post(form) {
    var e = document.getElementById("pierwszy");
    var txt = e.options[e.selectedIndex].text;

    k1 = document.getElementById('drugi');
    k1_old = document.getElementById(txt + '1').innerHTML;
    console.log('k1_old = ' + k1_old);
    k2 = document.getElementById('trzeci');
    k2_old = document.getElementById(txt + '2').innerHTML;


    form = document.getElementById("my-form");

    old1 = document.createElement('input');
    old1.style.visibility = 'hidden';
    old1.type = 'hidden';
    old1.name = 'kandydat1_old';
    old1.value = k1_old;
    form.appendChild(old1);

    old2 = document.createElement('input');
    old2.style.visibility = 'hidden';
    old2.type = 'hidden';
    old2.name = 'kandydat2_old';
    old2.value = k2_old;
    form.appendChild(old2);

    console.log('form = ' + form);

    if (k1.value.length === 0 || k2.value.length === 0) {
        alert('Proszę wprowadzić dane obydwu kandydatów.');
    } else {
        if (k1.value < 0 || k2.value < 0) {
            alert('Żaden z kanyddatów nie mógł dostać ujemnej liczby głosów.\nProszę wprowadzić poprawne dane.');
        } else {
            if (isNaN(k1.value) || isNaN(k2.value)) {
                alert('Wyniki poszczególnych kandydatów muszą być liczbami.\nProszę wprowadzić poprawne dane.');
            } else {

                post_form(form, old1, old2);
            }
        }
    }

}



function post_form(form, old1, old2) {
    $.ajax({
        type: 'POST',
        url: '/form_post/',
        dataType: 'json',
        data: $(form).serialize(),
        success: function(data) {
            if (data.status == "ok") {
                console.log("ok");
                form.reset();
                closeModal();
            }
            else {
                console.log("not ok");
                var message = "Te dane były ostatnio modyfikowane " + data.data_m + "\nprzez użytkownika " + data.user_m + ".\nCzy chcesz je nadpisać?";
                if (confirm(message) == true) {
                    old1.value = data.new1;
                    old2.value = data.new2;
                    post_form(form, old1, old2);
                }
            }
        }
    });
}



function closeConf() {
    var x = document.getElementById("cd-popup");
    x.style.visibility = 'hidden';
    closeModal();
}



function closeModal() {
    var x = document.getElementById("overlay");
    x.style.visibility = 'hidden';
}



function fillInProgress() {
    var question, questions, k1, k2;

    question = "/wyniki/wszystkie_glosy_list/";

    var xhttp = new XMLHttpRequest();

    xhttp.open("GET", question);

    xhttp.send();

    xhttp.addEventListener("load", function() {

        questions = JSON.parse(this.responseText);

        var pr1 = questions['wszystkie_glosy']['pr1'];
        var pr2 = questions['wszystkie_glosy']['pr2'];

        document.getElementById('imie1').innerHTML += ' ' +  pr1 + ' %';
        document.getElementById('imie2').innerHTML += ' ' +  pr2 + ' %';
        document.getElementById('prgb').value = pr1;

    });

}



function completeCandidates() {
    var question, questions, k1, k2;

    question = "/wyniki/kandydaci_list/";

    var xhttp = new XMLHttpRequest();

    xhttp.open("GET", question);

    xhttp.send();

    xhttp.addEventListener("load", function() {

        questions = JSON.parse(this.responseText);

        k1 = questions["kandydaci"];
        k1 = k1[0]['kandydat1'];

        k2 = questions["kandydaci"];
        k2 = k2[1]['kandydat2'];

        document.getElementById('imie1').innerHTML += k1;
        document.getElementById('imie11').innerHTML += k1;
        document.getElementById('imie111').innerHTML += k1;
        document.getElementById('imie1111').innerHTML += k1;
        document.getElementById('imie2').innerHTML += k2;
        document.getElementById('imie22').innerHTML += k2;
        document.getElementById('imie222').innerHTML += k2;
        document.getElementById('imie2222').innerHTML += k2;

        fillInProgress();

    });
}



window.onclick = function(event) {
    var modal = document.getElementById('overlay');
    if (event.target == modal) {
        modal.style.visibility = 'hidden';
    }
}
