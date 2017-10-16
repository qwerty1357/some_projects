<?php
    ini_set('display_errors', 1);
    error_reporting(E_ALL);
?>


<html lang = "en">

   <head>
      <title>Logi startowe linuxa</title>
      <link rel="stylesheet" href="load_logs.css">
      <script src="load_logs.js"></script>
   </head>

   <button class='back_btn'><a href = "logs.php" tite = "main"> BACK </a></button>

   <body>

        <div align='center'>
            <button class='btn2' id='btn_modal' onclick="show_logs_modal();"> filter </button>
            <button class='btn2' id='btn_modal_comp' onclick="show_logs_modal_comp();"> select to compare </button>
            <button class='btn2' id='btn_modal_stats' onclick="show_logs_modal_stats();"> stats </button>
            <button class='btn2' id='btn_modal_stats' onclick="show_logs_modal_delete();"> delete log </button>
        </div>


        <div align='center' class='modal' id='modal_window_delete'>
            <form align='center' action = "<?php $_PHP_SELF ?>" method = "GET">
                <p> ID: <input placeholder="ID" class="input_text_modal" name="log_id"> </input>
                </p>
                <p><button class='btn3' type=submit> delete </button></p>
            </form>
            <p><button class='btn3' id='modal_close' onclick='close_modal_delete()'> close </button></p>
        </div>

        <div align='center' class='modal' id='modal_window_stats'>
            <form align='center' action = "<?php $_PHP_SELF ?>" method = "GET">
                <p> Computer:
                    <select name="stats">
                        <?php
                            $conn = oci_connect('ak332284', 'h3jk4', NULL);
                            $stid = oci_parse($conn, "SELECT DISTINCT computer_name FROM logs");
                            oci_execute($stid);
                            while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                                foreach ($row as $item) {
                                    echo "<option value='$item'>$item</option>";
                                }
                            }
                        ?>
                    </select> &nbsp;
                </p>
                <p><button class='btn3' type=submit> find </button></p>
            </form>
            <p><button class='btn3' id='modal_close' onclick='close_modal_stats()'> close </button></p>
        </div>

        <div align='center' class='modal' id='modal_window_comp'>
            <form align='center' action = "<?php $_PHP_SELF ?>" method = "GET">
                <p> Computer 1:
                    <select name="comp1">
                        <?php
                            $conn = oci_connect('ak332284', 'h3jk4', NULL);
                            $stid = oci_parse($conn, "SELECT DISTINCT computer_name FROM logs");
                            oci_execute($stid);
                            while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                                foreach ($row as $item) {
                                    echo "<option value='$item'>$item</option>";
                                }
                            }
                        ?>
                    </select> &nbsp;
                </p>
                <p> Computer 2:
                    <select name="comp2">
                        <?php
                            $conn = oci_connect('ak332284', 'h3jk4', NULL);
                            $stid = oci_parse($conn, "SELECT DISTINCT computer_name FROM logs");
                            oci_execute($stid);
                            while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                                foreach ($row as $item) {
                                    echo "<option value='$item'>$item</option>";
                                }
                            }
                        ?>
                    </select> &nbsp;
                </p>
                <p><input type="checkbox" name="only_diff" value="diff" unchecked> Only different</p>
                <p> Pattern: <input placeholder="pattern" class="input_text_modal" name='pattern2'> </input>
                <p><button class='btn3' type=submit> compare </button></p>
            </form>
            <p><button class='btn3' id='modal_close' onclick='close_modal_comp()'> close </button></p>
        </div>


        <div align='center' class='modal' id='modal_window'>
            <form align='center' action = "<?php $_PHP_SELF ?>" method = "GET">
                <p> Device: <input placeholder="device" class="input_text_modal" name="device"> </input>
                </p>
                <p> Time: <input placeholder="from" class="input_text_modal" name="from"> </input>
                          <input placeholder="to" class="input_text_modal" name="to"> </input>
                </p>
                <p> Computer name:
                    <select name="level2">
                        <?php
                            $conn = oci_connect('ak332284', 'h3jk4', NULL);
                            $stid = oci_parse($conn, "SELECT DISTINCT computer_name FROM logs");
                            oci_execute($stid);
                            echo "<option value='all'>ALL</option>";
                            while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                                foreach ($row as $item) {
                                    echo "<option value='$item'>$item</option>";
                                }
                            }
                        ?>
                    </select> &nbsp;
                </p>
                <p> Pattern: <input placeholder="pattern" class="input_text_modal" name='pattern'> </input>
                </p>
                <p><button class='btn3' type=submit> find </button></p>
            </form>
            <p><button class='btn3' id='modal_close' onclick='close_modal()'> close </button></p>
        </div>

        <?php
            if (!empty($_GET['pattern'])) {
                $pt = "%" . $_GET['pattern'] . "%";
            } else {
                $pt = "%%";
            }
            if (!empty($_GET['from'])) {
                $from = $_GET['from'];
            } else {
                $from = 0;
            }
            if (!empty($_GET['to'])) {
                $to = $_GET['to'];
            } else {
                $to = 99999;
            }

            if (!empty($_GET['level2'])) {
                $computer = $_GET['level2'];
            }


            if (!empty($_GET['device'])) {
                $device = $_GET['device'];
                $conn = oci_connect('ak332284', 'h3jk4', NULL);

                if ($_GET['level2'] == 'all') {
                    if (!empty($_GET['pattern'])) {
                        $stid = oci_parse($conn, "SELECT id,
                                                  ((SELECT to_char(log_time, '0.999999') from dual WHERE log_time < 10)
                                                  UNION
                                                  (SELECT to_char(log_time) from dual WHERE log_time >= 10)),
                                                  device_name, message, computer_name FROM logs
                                                  WHERE (device_name = :dev AND message LIKE :pattern)
                                                  AND (log_time >= :time_from) AND (log_time < :time_to) ORDER BY log_time");
                    oci_bind_by_name($stid, ":pattern", $pt);
                    } else {
                        $stid = oci_parse($conn, "SELECT id,
                                                  ((SELECT to_char(log_time, '0.999999') from dual WHERE log_time < 10)
                                                  UNION
                                                  (SELECT to_char(log_time) from dual WHERE log_time >= 10)),
                                                  device_name, message, computer_name FROM logs
                                                  WHERE (device_name = :dev)
                                                  AND (log_time >= :time_from) AND (log_time < :time_to) ORDER BY log_time");
                    }

                    oci_bind_by_name($stid, ":dev", $device);
                    oci_bind_by_name($stid, ":time_from", $from);
                    oci_bind_by_name($stid, ":time_to", $to);

                    oci_execute($stid);

                    echo "<table align ='center'>
                            <tr>
                                <th>ID</th>
                                <th>TIME</th>
                                <th>DEVICE</th>
                                <th>MESSAGE</th>
                                <th>COMPUTER_NAME</th>
                            </tr>";
                    while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                        $ops = 0;
                        $fail = 0;
                        echo "<tr>\n";
                        foreach ($row as $item) {
                            echo "    <td align='center' class='log'>" . ($item !== null ? htmlentities($item, ENT_QUOTES) : "&nbsp;") . "</td>\n";
                            if (empty($row['MESSAGE']) || empty($row['DEVICE_NAME'])) {
                                $ops = 1;
                            }
                            if (!empty($row['MESSAGE'])) {
                                if (strpos($row['MESSAGE'], 'fail') !== false || strpos($row['MESSAGE'], 'error') !== false || strpos($row['MESSAGE'], "not") !== false || strpos($row['MESSAGE'], 'Error') !== false) {
                                    $fail = 1;
                                }
                            }
                        }
                        if ($ops) {
                            echo "<td> <img class='err' src='err.png' /> </td>";
                        }
                        if ($fail) {
                            echo "<td> <img class='err' src='fail.ico' /> </td>";
                        }
                        echo "</tr>\n";
                    }
                    echo "</table>\n";
                } else {
                    if (!empty($_GET['pattern'])) {
                        $stid = oci_parse($conn, "SELECT id,
                                                  ((SELECT to_char(log_time, '0.999999') from dual WHERE log_time < 10)
                                                  UNION
                                                  (SELECT to_char(log_time) from dual WHERE log_time >= 10)),
                                                  device_name, message, computer_name FROM logs
                                                  WHERE (device_name = :dev AND message LIKE :pattern)
                                                  AND (log_time >= :time_from) AND (log_time < :time_to) AND computer_name = :comp ORDER BY log_time");
                        oci_bind_by_name($stid, ":pattern", $pt);
                    } else {
                        $stid = oci_parse($conn, "SELECT id,
                                                  ((SELECT to_char(log_time, '0.999999') from dual WHERE log_time < 10)
                                                  UNION
                                                  (SELECT to_char(log_time) from dual WHERE log_time >= 10)),
                                                  device_name, message, computer_name FROM logs
                                                  WHERE (device_name = :dev)
                                                  AND (log_time >= :time_from) AND (log_time < :time_to) AND computer_name = :comp ORDER BY log_time");
                    }

                    oci_bind_by_name($stid, ":dev", $device);
                    oci_bind_by_name($stid, ":time_from", $from);
                    oci_bind_by_name($stid, ":time_to", $to);
                    oci_bind_by_name($stid, ":comp", $computer);
                    oci_execute($stid);

                    echo "<table align ='center'>
                            <tr>
                                <th>ID</th>
                                <th>TIME</th>
                                <th>DEVICE</th>
                                <th>MESSAGE</th>
                                <th>COMPUTER_NAME</th>
                            </tr>";
                    while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                        echo "<tr>\n";
                        $ops = 0;
                        $fail = 0;
                        foreach ($row as $item) {
                            echo "    <td align='center' class='log'>" . ($item !== null ? htmlentities($item, ENT_QUOTES) : "&nbsp;") . "</td>\n";
                            if (empty($row['MESSAGE']) || empty($row['DEVICE_NAME'])) {
                                $ops = 1;
                            }
                            if (!empty($row['MESSAGE'])) {
                                if (strpos($row['MESSAGE'], 'fail') !== false || strpos($row['MESSAGE'], 'error') !== false || strpos($row['MESSAGE'], "not") !== false || strpos($row['MESSAGE'], 'Error') !== false) {
                                    $fail = 1;
                                }
                            }
                        }
                        if ($ops) {
                            echo "<td> <img class='err' src='err.png' /> </td>";
                        }
                        if ($fail) {
                            echo "<td> <img class='err' src='fail.ico' /> </td>";
                        }
                        echo "</tr>\n";
                    }
                    echo "</table>\n";
                }
            } else if (!empty($_GET['level2'])) {
                $conn = oci_connect('ak332284', 'h3jk4', NULL);
                if ($_GET['level2'] == 'all') {
                    if (!empty($_GET['pattern'])) {
                        $stid = oci_parse($conn, "SELECT id,
                                                  ((SELECT to_char(log_time, '0.999999') from dual WHERE log_time < 10)
                                                  UNION
                                                  (SELECT to_char(log_time) from dual WHERE log_time >= 10)),
                                                  device_name, message, computer_name FROM logs
                                                  WHERE message LIKE :pattern
                                                  AND (log_time >= :time_from AND log_time < :time_to) ORDER BY log_time");
                        oci_bind_by_name($stid, ":pattern", $pt);
                    } else {
                        $stid = oci_parse($conn, "SELECT id,
                                                  ((SELECT to_char(log_time, '0.999999') from dual WHERE log_time < 10)
                                                  UNION
                                                  (SELECT to_char(log_time) from dual WHERE log_time >= 10)),
                                                  device_name, message, computer_name FROM logs
                                                  WHERE (log_time >= :time_from AND log_time < :time_to) ORDER BY log_time");
                    }

                    oci_bind_by_name($stid, ":time_from", $from);
                    oci_bind_by_name($stid, ":time_to", $to);
                    oci_execute($stid);

                    echo "<table align ='center'>
                            <tr>
                                <th>ID</th>
                                <th>TIME</th>
                                <th>DEVICE</th>
                                <th>MESSAGE</th>
                                <th>COMPUTER_NAME</th>
                            </tr>";
                    while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                        echo "<tr>\n";
                        $ops = 0;
                        $fail = 0;
                        foreach ($row as $item) {
                            echo "    <td align='center' class='log' class='message_table'>" . ($item !== null ? htmlentities($item, ENT_QUOTES) : "&nbsp;") . "</td>\n";
                            if (empty($row['MESSAGE']) || empty($row['DEVICE_NAME'])) {
                                $ops = 1;
                            }
                            if (!empty($row['MESSAGE'])) {
                                if (strpos($row['MESSAGE'], 'fail') !== false || strpos($row['MESSAGE'], 'error') !== false || strpos($row['MESSAGE'], "not") !== false || strpos($row['MESSAGE'], 'Error') !== false) {
                                    $fail = 1;
                                }
                            }
                        }
                        if ($ops) {
                            echo "<td class='ico'> <img class='err' src='err.png' /> </td>";
                        }
                        if ($fail) {
                            echo "<td> <img class='err' src='fail.ico' /> </td>";
                        }
                        echo "</tr>\n";
                    }
                    echo "</table>\n";

                } else {
                    if (!empty($_GET['pattern'])) {
                        $stid = oci_parse($conn, "SELECT id,
                                                  ((SELECT to_char(log_time, '0.999999') from dual WHERE log_time < 10)
                                                  UNION
                                                  (SELECT to_char(log_time) from dual WHERE log_time >= 10)),
                                                  device_name, message, computer_name FROM logs
                                                  WHERE (computer_name = :comp AND message LIKE :pattern)
                                                  AND (log_time >= :time_from) AND (log_time < :time_to) ORDER BY log_time");
                        oci_bind_by_name($stid, ":pattern", $pt);
                    } else {
                        $stid = oci_parse($conn, "SELECT id,
                                                  ((SELECT to_char(log_time, '0.999999') from dual WHERE log_time < 10)
                                                  UNION
                                                  (SELECT to_char(log_time) from dual WHERE log_time >= 10)),
                                                  device_name, message, computer_name FROM logs
                                                  WHERE (computer_name = :comp)
                                                  AND (log_time >= :time_from) AND (log_time < :time_to) ORDER BY log_time");
                    }

                    oci_bind_by_name($stid, ":time_from", $from);
                    oci_bind_by_name($stid, ":time_to", $to);
                    oci_bind_by_name($stid, ":comp", $computer);
                    oci_execute($stid);

                    echo "<table align ='center'>
                            <tr>
                                <th>ID</th>
                                <th>TIME</th>
                                <th>DEVICE</th>
                                <th>MESSAGE</th>
                                <th>COMPUTER_NAME</th>
                            </tr>";
                    while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                        $ops = 0;
                        $fail = 0;
                        echo "<tr>\n";
                        foreach ($row as $item) {
                            echo "    <td align='center' class='log'>" . ($item !== null ? htmlentities($item, ENT_QUOTES) : "&nbsp;") . "</td>\n";
                            if (empty($row['MESSAGE']) || empty($row['DEVICE_NAME'])) {
                                $ops = 1;
                            }
                            if (!empty($row['MESSAGE'])) {
                                if (strpos($row['MESSAGE'], 'fail') !== false || strpos($row['MESSAGE'], 'error') !== false || strpos($row['MESSAGE'], "not") !== false || strpos($row['MESSAGE'], 'Error') !== false) {
                                    $fail = 1;
                                }
                            }
                        }
                        if ($ops) {
                            echo "<td> <img class='err' src='err.png' /> </td>";
                        }
                        if ($fail) {
                            echo "<td> <img class='err' src='fail.ico' /> </td>";
                        }
                        echo "</tr>\n";
                    }
                    echo "</table>\n";
                }

            }

            if (!empty($_GET['comp1']) && !empty($_GET['comp2'])) {
                $comp1 = $_GET['comp1'];
                $comp2 = $_GET['comp2'];
                $conn = oci_connect('ak332284', 'h3jk4', NULL);


                if (isset($_GET['only_diff'])) {
                    if (!empty($_GET['pattern2'])) {
                        $stid = oci_parse($conn,  "SELECT ((SELECT to_char(log_time, '0.999999') from dual WHERE log_time < 10)
                                                   UNION
                                                   (SELECT to_char(log_time) from dual WHERE log_time >= 10)) as time1,
                                                   l1.message as message, l1.device_name as device, NULL as mes2, NULL as time2
                                                   FROM logs l1 WHERE (l1.computer_name = :c1 AND (l1.message LIKE :p OR l1.device_name LIKE :p))
                                                   AND (l1.message  NOT IN (SELECT l2.message FROM logs l2 where l2.computer_name = :c2 AND l1.device_name=l2.device_name))
                                                   AND (l1.message IS NOT NULL AND l1.device_name IS NOT NULL)
                                                   UNION ALL
                                                   SELECT NULL as time1,
                                                   NULL as message, l1.device_name as device,
                                                   l1.message as mes2,
                                                   ((SELECT to_char(log_time, '0.999999') from dual WHERE log_time < 10)
                                                   UNION
                                                   (SELECT to_char(log_time) from dual WHERE log_time >= 10)) as time2
                                                   FROM logs l1 WHERE (l1.computer_name = :c2 AND (l1.message LIKE :p OR l1.device_name LIKE :p))
                                                   AND (l1.message  NOT IN (SELECT l2.message FROM logs l2 where l2.computer_name = :c1 and l1.device_name=l2.device_name))
                                                   AND (l1.message IS NOT NULL AND l1.device_name IS NOT NULL)
                                                   ORDER BY device, time1, time2
                                                   ");
                       oci_bind_by_name($stid, ":c1", $comp1);
                       oci_bind_by_name($stid, ":c2", $comp2);
                       $pattern2 = "%" . $_GET['pattern2'] . "%";
                       oci_bind_by_name($stid, ":p", $pattern2);
                       oci_execute($stid);
                   } else {
                       $stid = oci_parse($conn,  "SELECT ((SELECT to_char(log_time, '0.999999') from dual WHERE log_time < 10)
                                                  UNION
                                                  (SELECT to_char(log_time) from dual WHERE log_time >= 10)) as time1,
                                                  l1.message as message, l1.device_name as device, NULL as mes2, NULL as time2
                                                  FROM logs l1 WHERE (l1.computer_name = :c1
                                                  AND l1.message  NOT IN (SELECT l2.message FROM logs l2 where l2.computer_name = :c2 AND l1.device_name=l2.device_name))
                                                  AND (l1.message IS NOT NULL AND l1.device_name IS NOT NULL)
                                                  UNION ALL
                                                  SELECT NULL as time1,
                                                  NULL as message, l1.device_name as device,
                                                  l1.message as mes2,
                                                  ((SELECT to_char(log_time, '0.999999') from dual WHERE log_time < 10)
                                                  UNION
                                                  (SELECT to_char(log_time) from dual WHERE log_time >= 10)) as time2
                                                  FROM logs l1 WHERE (l1.computer_name = :c2
                                                  AND l1.message  NOT IN (SELECT l2.message FROM logs l2 where l2.computer_name = :c1 and l1.device_name=l2.device_name))
                                                  AND (l1.message IS NOT NULL AND l1.device_name IS NOT NULL)
                                                  ORDER BY device, time1, time2
                                                  ");
                      oci_bind_by_name($stid, ":c1", $comp1);
                      oci_bind_by_name($stid, ":c2", $comp2);
                      oci_execute($stid);
                   }

                   echo "<table align ='center'>
                           <tr>
                               <th>TIME 1</th>
                               <th>$comp1 MESSAGE</th>
                               <th>DEVICE</th>
                               <th>$comp2 MESSAGE</th>
                               <th>TIME 2</th>

                           </tr>";

                   while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                       echo "<tr>\n";

                       foreach ($row as $item) {

                           echo " <td align='center' class='log' class='message_table'>" . ($item !== null ? htmlentities($item, ENT_QUOTES) : "&nbsp;") . "</td>\n";
                       }


                       echo "</tr>\n";
                   }
                   echo "</table>\n";
                } else {
                    if (!empty($_GET['pattern2'])) {
                        $stid = oci_parse($conn,  "SELECT ((SELECT to_char(log_time, '0.999999') from dual WHERE log_time < 10)
                                                   UNION
                                                   (SELECT to_char(log_time) from dual WHERE log_time >= 10)) as time1,
                                                   l1.message as message, l1.device_name as device, NULL as mes2, NULL as time2
                                                   FROM logs l1 WHERE (l1.computer_name = :c1 AND (l1.message LIKE :p OR l1.device_name LIKE :p))
                                                   AND (l1.message  NOT IN (SELECT l2.message FROM logs l2 where l2.computer_name = :c2 and l1.device_name=l2.device_name))
                                                   AND (l1.message IS NOT NULL AND l1.device_name IS NOT NULL)
                                                   UNION ALL
                                                   SELECT NULL as time1,
                                                   NULL as message, l1.device_name as device,
                                                   l1.message as mes2,
                                                   ((SELECT to_char(log_time, '0.999999') from dual WHERE log_time < 10)
                                                   UNION
                                                   (SELECT to_char(log_time) from dual WHERE log_time >= 10)) as time2
                                                   FROM logs l1 WHERE  (l1.computer_name = :c2 AND (l1.message LIKE :p OR l1.device_name LIKE :p))
                                                   AND (l1.message  NOT IN (SELECT l2.message FROM logs l2 where l2.computer_name = :c1 and l1.device_name=l2.device_name))
                                                   AND (l1.message IS NOT NULL AND l1.device_name IS NOT NULL)
                                                   UNION
                                                   SELECT DISTINCT ((SELECT to_char(l1.log_time, '0.999999') from dual WHERE l1.log_time < 10)
                                                   UNION
                                                   (SELECT to_char(l1.log_time) from dual WHERE l1.log_time >= 10)) as time1,
                                                   l1.message as m1, l1.device_name as device, l2.message as m2,
                                                   ((SELECT to_char(l2.log_time, '0.999999') from dual WHERE l2.log_time < 10)
                                                   UNION
                                                   (SELECT to_char(l2.log_time) from dual WHERE l2.log_time >= 10)) as time2
                                                   FROM logs l1 LEFT
                                                   JOIN logs l2 ON l1.message = l2.message AND l1.device_name = l2.device_name WHERE ((l1.computer_name = :c1 AND l2.computer_name = :c2) AND (l1.message LIKE :p OR l1.device_name LIKE :p) AND (l1.message IS NOT NULL AND l1.device_name IS NOT NULL))
                                                   ORDER BY device, time1, time2
                                                   ");


                       oci_bind_by_name($stid, ":c1", $comp1);
                       oci_bind_by_name($stid, ":c2", $comp2);
                       $pattern2 = "%" . $_GET['pattern2'] . "%";
                       oci_bind_by_name($stid, ":p", $pattern2);
                       oci_execute($stid);

                    } else {
                        $stid = oci_parse($conn,  "SELECT ((SELECT to_char(log_time, '0.999999') from dual WHERE log_time < 10)
                                                   UNION
                                                   (SELECT to_char(log_time) from dual WHERE log_time >= 10)) as time1,
                                                   l1.message as message, l1.device_name as device, NULL as mes2, NULL as time2
                                                   FROM logs l1 WHERE (l1.computer_name = :c1
                                                   AND l1.message  NOT IN (SELECT l2.message FROM logs l2 where l2.computer_name = :c2 and l1.device_name=l2.device_name))
                                                   AND (l1.message IS NOT NULL AND l1.device_name IS NOT NULL)
                                                   UNION ALL
                                                   SELECT NULL as time1,
                                                   NULL as message, l1.device_name as device,
                                                   l1.message as mes2,
                                                   ((SELECT to_char(log_time, '0.999999') from dual WHERE log_time < 10)
                                                   UNION
                                                   (SELECT to_char(log_time) from dual WHERE log_time >= 10)) as time2
                                                   FROM logs l1 WHERE (l1.computer_name = :c2
                                                   AND l1.message  NOT IN (SELECT l2.message FROM logs l2 where l2.computer_name = :c1 and l1.device_name=l2.device_name))
                                                   AND (l1.message IS NOT NULL AND l1.device_name IS NOT NULL)
                                                   UNION
                                                   SELECT DISTINCT ((SELECT to_char(l1.log_time, '0.999999') from dual WHERE l1.log_time < 10)
                                                   UNION
                                                   (SELECT to_char(l1.log_time) from dual WHERE l1.log_time >= 10)) as time1,
                                                   l1.message as m1, l1.device_name as device, l2.message as m2,
                                                   ((SELECT to_char(l2.log_time, '0.999999') from dual WHERE l2.log_time < 10)
                                                   UNION
                                                   (SELECT to_char(l2.log_time) from dual WHERE l2.log_time >= 10)) as time2
                                                   FROM logs l1 LEFT
                                                   JOIN logs l2 ON l1.message = l2.message AND l1.device_name = l2.device_name WHERE ((l1.computer_name = :c1 AND l2.computer_name = :c2) AND (l1.message IS NOT NULL AND l1.device_name IS NOT NULL))
                                                   ORDER BY device, time1, time2
                                                   ");


                       oci_bind_by_name($stid, ":c1", $comp1);
                       oci_bind_by_name($stid, ":c2", $comp2);
                       oci_execute($stid);
                   }

                   echo "<table align ='center'>
                           <tr>
                               <th>TIME 1</th>
                               <th>$comp1 MESSAGE</th>
                               <th>DEVICE</th>
                               <th>$comp2 MESSAGE</th>
                               <th>TIME 2</th>

                           </tr>";

                   while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                       echo "<tr>\n";
                       $ops = 0;
                       foreach ($row as $item) {
                           if (empty($row['MESSAGE']) || empty($row['MES2'])) {
                               $ops = 1;
                           }
                           echo " <td align='center' class='log' class='message_table'>" . ($item !== null ? htmlentities($item, ENT_QUOTES) : "&nbsp;") . "</td>\n";
                       }
                       if ($ops) {
                           echo "<td> <img class='err' src='redlight.png' /> </td>";
                       }

                       echo "</tr>\n";
                   }
                   echo "</table>\n";

                }





            }


            /* ------------------- STATS -------------------------- */

            if (!empty($_GET['stats'])) {
                $conn = oci_connect('ak332284', 'h3jk4', NULL);
                $comp = $_GET['stats'];
                $stid = oci_parse($conn, 'SELECT COUNT(*) FROM logs WHERE computer_name = :comp');
                oci_bind_by_name($stid, ":comp", $comp);
                oci_execute($stid);
                echo "<table align ='center'>";
                echo "<tr>\n";
                while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                    foreach ($row as $item) {
                        echo "<td align='center' class='log_stat'>NUMBER OF LOGS IN DATABASE </td> <td align='center' class='log_stat'> $item</td>";
                    }
                }
                echo "</tr>\n";




                $stid = oci_parse($conn, 'SELECT COUNT(*) FROM uploads_history WHERE computer_name = :comp');
                oci_bind_by_name($stid, ":comp", $comp);
                oci_execute($stid);

                echo "<p align='center' class='head_stats'> Statistics for $comp </p>";

                echo "<tr>\n";
                while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                    foreach ($row as $item) {
                        echo "<td align='center' class='log_stat'>NUMBER OF UPLOADS </td> <td align='center' class='log_stat'> $item</td>";
                    }
                }
                echo "</tr>\n";




                $stid = oci_parse($conn, "SELECT name, surname, login,  to_char(upload_time, 'Dy DD-Mon-YYYY HH24:MI:SS'), computer_name
                                          FROM uploads_history JOIN users
                                          ON users.login = uploads_history.upload_user_login
                                          WHERE upload_time = (SELECT MAX(upload_time)
                                          FROM uploads_history WHERE computer_name = :comp) AND computer_name = :comp");

                oci_bind_by_name($stid, ":comp", $comp);
                oci_execute($stid);
                echo "<tr> <td align='center' class='log_stat'> LAST MODIFICATION </td>\n <td align='center' class='log_stat'>";
                $row = oci_fetch_row($stid);
                echo "<p>Made by: &nbsp &nbsp" . $row[0] . " " . $row[1] .  " (" . $row[2] . ")" . "</p>";
                echo "<p>On: &nbsp &nbsp" . $row[3] . "</p>";
                echo "</td></tr>";



                $stid = oci_parse($conn, "SELECT COUNT(*) FROM logs WHERE computer_name = :comp AND ((message LIKE '%not%' OR message LIKE '%error%') OR message LIKE '%fail%')");
                oci_bind_by_name($stid, ":comp", $comp);
                oci_execute($stid);

                echo "<tr>\n";
                while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                    foreach ($row as $item) {
                        echo "<td align='center'> <img align='center' class='err' src='fail.ico' /> </td> <td align='center' class='log_stat'> $item</td>";
                    }
                }
                echo "</tr>\n";



                $stid = oci_parse($conn, "SELECT COUNT(*) FROM logs WHERE computer_name = :comp AND (message IS NULL OR device_name IS NULL)");
                oci_bind_by_name($stid, ":comp", $comp);
                oci_execute($stid);

                echo "<tr>\n";
                while ($row = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                    foreach ($row as $item) {
                        echo "<td align='center'> <img align='center' class='err' src='err.png' /> </td> <td align='center' class='log_stat'> $item</td>";
                    }
                }
                echo "</tr>\n";



                $stid = oci_parse($conn, "SELECT message, device_name FROM logs WHERE computer_name = :comp AND device_name LIKE '%Linux%'");
                oci_bind_by_name($stid, ":comp", $comp);
                oci_execute($stid);

                echo "<tr> <td align='center' class='log_stat'> LINUX VERSION: </td>\n <td align='center' class='log_stat'>";
                $row = oci_fetch_row($stid);
                echo "<p>" . substr($row[1], 14, -1)  . "</p>";
                echo "</td></tr>";

                echo "</table>";
            }



            if (!empty($_GET['log_id'])) {
                $conn = oci_connect('ak332284', 'h3jk4', NULL);
                $log_id = $_GET['log_id'];
                $stid = oci_parse($conn, "DELETE FROM logs WHERE id = :log_id");
                oci_bind_by_name($stid, ":log_id", $log_id);
                oci_execute($stid);
            }


         ?>


   </body>
</html>
