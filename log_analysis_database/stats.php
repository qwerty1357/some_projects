<?php
    ini_set('display_errors', 1);
    error_reporting(E_ALL);
?>


<html lang = "en">

    <style>



    </style>

    <head>
        <title>Statistics</title>
        <link rel="stylesheet" href="stats.css">
    </head>

    <button class='back_btn'><a href = "logs.php" tite = "main"> BACK </a></button>

    <body>
        <h2> General statistics </h2>

        <?php
            $conn = oci_connect('ak332284', 'h3jk4', NULL);
            $stid = oci_parse($conn, 'select number_of_logs from dual');
            oci_execute($stid);

            echo "<table align ='center'>";
            echo "<tr>\n";
            while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                foreach ($row as $item) {
                    echo "<td align='center' class='log'>NUMBER OF LOGS IN DATABASE </td> <td align='center' class='log'> $item</td>";
                }
            }
            echo "</tr>\n";

            $stid = oci_parse($conn, 'select number_of_files from dual');
            oci_execute($stid);
            echo "<tr>\n";
            while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                foreach ($row as $item) {
                    echo "<td align='center' class='log'>NUMBER OF UPLOADED FILES </td> <td align='center' class='log'> $item</td>";
                }
            }
            echo "</tr>\n";

            $stid = oci_parse($conn, 'select number_of_users from dual');
            oci_execute($stid);
            echo "<tr>\n";
            while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                foreach ($row as $item) {
                    echo "<td align='center' class='log'>NUMBER OF USERS IN DATABASE </td> <td align='center' class='log'> $item</td>";
                }
            }
            echo "</tr>\n";

            $stid = oci_parse($conn, 'SELECT DISTINCT login from users');
            oci_execute($stid);
            echo "<tr> <td align='center' class='log'> USERS </td>\n <td align='center' class='log'>";
            while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                foreach ($row as $item) {
                    echo " $item &nbsp &nbsp &nbsp";
                }
            }
            echo "</td></tr>\n";

            $stid = oci_parse($conn, 'SELECT DISTINCT computer_name from uploads_history');
            oci_execute($stid);
            echo "<tr> <td align='center' class='log'> COMPUTERS </td>\n <td align='center' class='log'>";
            while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                foreach ($row as $item) {
                    echo " $item &nbsp &nbsp &nbsp";
                }
            }
            echo "</td></tr>";


            $stid = oci_parse($conn, "SELECT name, surname, to_char(upload_time, 'Dy DD-Mon-YYYY HH24:MI:SS'), computer_name
                                      FROM uploads_history JOIN users
                                      ON users.login = uploads_history.upload_user_login
                                      WHERE upload_time = (SELECT MAX(upload_time)
                                      FROM uploads_history)");
            oci_execute($stid);
            echo "<tr> <td align='center' class='log'> LAST MODIFICATION </td>\n <td align='center' class='log'>";
            $row = oci_fetch_row($stid);
            echo "<p>Made by: &nbsp &nbsp" . $row[0] . " " . $row[1] . "</p>";
            echo "<p>On: &nbsp &nbsp" . $row[2] . "</p>";
            echo "<p>Uploaded file: &nbsp &nbsp" . $row[3] . "</p>";
            echo "</td></tr>";


            $stid = oci_parse($conn, 'SELECT COUNT(*) from uploads_history');
            oci_execute($stid);
            echo "<tr> <td align='center' class='log'> NUMBER OF UPLOADS </td>\n <td align='center' class='log'>";
            while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                foreach ($row as $item) {
                    echo " $item &nbsp &nbsp &nbsp";
                }
            }
            echo "</td></tr>";

            echo "</table>\n";

        ?>

    </body>

</html>
