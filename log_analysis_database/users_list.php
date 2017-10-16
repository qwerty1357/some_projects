<?php
    ini_set('display_errors', 1);
    error_reporting(E_ALL);
?>


<html lang = "en">

    <head>
        <title>Users list</title>
        <link rel="stylesheet" href="users_list.css">
        <script src="users_list.js"></script>
    </head>

    <button class='back_btn'><a href = "logs.php" tite = "main"> BACK </a></button>

    <body>
        <h2> Users </h2>

        <div align='center'>
            <button align='center' class='btn2' id='btn_modal_users' onclick="add_user_modal();"> add user </button>
        </div>

        <div align='center' class='modal' id='modal_window_users'>
            <form align='center' action = "<?php $_PHP_SELF ?>" method = "GET" >
                <p class="form_text_modal"> Name: <input placeholder="name" class="input_text_modal" name='name'> </input></p>
                <p>Surname: <input placeholder="surname" class="input_text_modal" name="surname" > </input></p>
                <p>Login: <input placeholder="login" class="input_text_modal" name='login'> </input></p>
                <p><button class='btn3' type=submit > add user </button></p>
            </form>
            <p><button class='btn3' id='modal_close' onclick="close_modal()"> close </button></p>
        </div>

        <?php
            $conn = oci_connect('ak332284', 'h3jk4', NULL);
            if (!$conn) {
                $m = oci_error();
                trigger_error(htmlentities($m['message']), E_USER_ERROR);
            }

            if (!empty($_GET['name']) && !empty($_GET['surname']) && !empty($_GET['login'])) {
                $name = $_GET['name'];
                $surname = $_GET['surname'];
                $login = $_GET['login'];

                $insert = oci_parse($conn, "BEGIN :result:=add_user(:name_ins, :surname_ins, :login_ins); END;");

                oci_bind_by_name($insert, ":name_ins", $name);
                oci_bind_by_name($insert, ":surname_ins", $surname);
                oci_bind_by_name($insert, ":login_ins", $login);
                oci_bind_by_name($insert, ":result", $res);

                oci_execute($insert);

                if ($res < 1) {
                    echo '<script type="text/javascript">',
                         'jsAlert();',
                         '</script>';
                }

            }

            $stid = oci_parse($conn, "SELECT * FROM users ORDER BY ID");
            oci_execute($stid);

            echo "<table align ='center'>
                    <tr>
                        <th>ID</th>
                        <th>NAME</th>
                        <th>SURNAME</th>
                        <th>LOGIN</th>
                    </tr>";
            while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                echo "<tr>\n";
                foreach ($row as $item) {
                    echo "    <td align='center' class='log'>" . ($item !== null ? htmlentities($item, ENT_QUOTES) : "&nbsp;") . "</td>\n";
                }
                echo "</tr>\n";
            }
            echo "</table>\n";


        ?>

    </body>

</html>
