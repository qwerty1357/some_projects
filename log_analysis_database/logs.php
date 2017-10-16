<?php
    ini_set('display_errors', 1);
    error_reporting(E_ALL);
?>


<html lang = "en">

   <head>
      <title>Logs</title>
      <link rel="stylesheet" href="logs.css">
   </head>

   <body>

      <h2> Linux logs </h2>
      <div align='center'>
          <p><button class='btn' id='btn_modal' action="load_logs"><a href = "load_logs.php" tite = "main"> logs </a></button></p>
          <p><button class='btn' id='btn_modal' action="load_logs"><a href = "uploads_history.php" tite = "main"> uploads history </a></button></p>
          <p><button class='btn' id='btn_modal' action="load_logs"><a href = "users_list.php" tite = "main">  users list </a></button></p>
          <p><button class='btn' id='btn_modal' action="load_logs"><a href = "stats.php" tite = "main">  general statistics  </a></button></p>
      </div>
   </body>
</html>
