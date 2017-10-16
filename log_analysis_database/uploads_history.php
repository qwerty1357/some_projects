<?php
    ini_set('display_errors', 1);
    error_reporting(E_ALL);
?>


<html lang = "en">
    <head>
        <title>Uploads history</title>
        <link rel="stylesheet" href="uploads_history.css">
        <script src="uploads_history.js"></script>
    </head>
    <button class='back_btn'><a href = "logs.php" tite = "main"> BACK </a></button>
    <body>
        <h2> Uploads history </h2>

        <div align='center'>
            <button class='btn2' id='btn_modal_files' onclick="add_file_modal();"> load logs </button>
        </div>
        <?php
            $conn = oci_connect('ak332284', 'h3jk4', NULL);
        ?>

        <div align='center' class='modal' id='modal_window_files'>
            <form align='center' id='file_upload' action = "<?php $_PHP_SELF ?>" method = "GET">
                <p> File: &nbsp;
                    <select name="level1">
                        <?php
                            if ($handle = opendir('/home/students/inf/a/ak332284/public_html/PHP_files')) {
                                while (false !== ($entry = readdir($handle))) {
                                    if ($entry != "." && $entry != ".." && $entry != "logs.png") {
                                        echo "<option value='$entry'>$entry</option>";
                                    }
                                }
                                echo "</div>";
                                closedir($handle);
                            }
                        ?>
                    </select> &nbsp;
                </p>

                <p> User: &nbsp;
                    <select name="level2">
                        <?php
                            $conn = oci_connect('ak332284', 'h3jk4', NULL);
                            $stid = oci_parse($conn, "SELECT login FROM users ORDER BY login");
                            oci_execute($stid);
                            while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                                foreach ($row as $item) {
                                    echo "<option value='$item'>$item</option>";
                                }
                            }
                        ?>
                    </select> &nbsp;
                </p>
                <p><button class='btn3' type=submit> Load file </button></p>
            </form>
            <p><button class='btn3' id='modal_close' onclick='close_modal()'> close </button></p>
        </div>



        <?php
            if (!empty($_GET['level1']) && !empty($_GET['level2'])) {
                $temp = $_GET['level1'];
                $upload_user = $_GET['level2'];
                $file_handle = fopen("/home/students/inf/a/ak332284/public_html/PHP_files/$temp", "r");
                $comp = $temp;
                $check = oci_parse($conn, "BEGIN :result:=logs_in_database(:comp); END;");
                oci_bind_by_name($check, ":comp", $comp);
                oci_bind_by_name($check, ":result", $res);
                oci_execute($check);

                if ($res > 0) {
                    $remove = oci_parse($conn, "BEGIN remove_logs(:comp); END;");
                    oci_bind_by_name($remove, ":comp", $comp);
                    oci_execute($remove);
                }

                while (!feof($file_handle)) {

                   $line = fgets($file_handle);
                   $device_name = preg_split('[:\s]', $line, -1, PREG_SPLIT_NO_EMPTY);
                   $msg = preg_split('[:\s]', $line, -1, PREG_SPLIT_NO_EMPTY);
                   if (isset($device_name[0])) {
                       $device_name = preg_split('[\]\s]', $device_name[0], -1, PREG_SPLIT_NO_EMPTY);
                   }
                   $chars2 = preg_split('[\[*\]]', $line, -1, PREG_SPLIT_NO_EMPTY);
                   if (!empty($chars2[0])) {
                       $log_time = preg_split('[\[+]', $chars2[0], -1, PREG_SPLIT_NO_EMPTY);
                   }

                   if (!isset($device_name[1])) {
                       $device_name = "";
                   }

                   if(!is_numeric($log_time[0])) {
                        $log_time[0] = 0;
                    }

                   $insert = oci_parse($conn, "BEGIN add_log(:time, :dev, :msg, :comp); END;");
                   oci_bind_by_name($insert, ":time", $log_time[0]);
                   oci_bind_by_name($insert, ":dev", $device_name[1]);
                   oci_bind_by_name($insert, ":msg", $msg[1]);
                   oci_bind_by_name($insert, ":comp", $comp);
                   oci_execute($insert);
                }

                $insert = oci_parse($conn, "BEGIN update_history(:login, :comp); END;");
                oci_bind_by_name($insert, ":login", $upload_user);
                oci_bind_by_name($insert, ":comp", $comp);

                oci_execute($insert);

                fclose($file_handle);

            }
        ?>


        <?php
            $conn = oci_connect('ak332284', 'h3jk4', NULL);
            $stid = oci_parse($conn, "SELECT * FROM uploads_history");
            oci_execute($stid);
            $tmp = 0;

            while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                if (!$tmp) {
                    echo "<table align ='center'>
                            <tr>
                                <th>USER</th>
                                <th>UPLOAD TIME</th>
                                <th>COMPUTER</th>
                            </tr>";
                    $tmp = 1;
                }
                echo "<tr>\n";
                foreach ($row as $item) {
                    echo "    <td align='center' class='element'>" . ($item !== null ? htmlentities($item, ENT_QUOTES) : "&nbsp;") . "</td>\n";
                }
                echo "</tr>\n";
            }
            echo "</table>\n";

        ?>
    </body>

</html>
