<?php
session_start();

function addAdmin()
{

    $name_Field = $_POST['username'];
    $password_field = $_POST['password'];

    $payload = json_encode(array("username" => $name_Field, "password" => $password_field));
    echo $payload;
    $ch = curl_init('https://socoolbus.herokuapp.com/adminPanel/addAdmin');
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
    curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type:application/json'));


    // execute!
    $response = curl_exec($ch);
    $httpcode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    // close the connection, release resources used
    curl_close($ch);

    // do anything you want with your response
    if ($httpcode == 200) {
        $json = json_decode($response, true);

        echo "<script>alert('Operasyon başarılı!');</script>"; //Neden bilmiyorum ama çalışmıyo bu alert
        //echo($enter_review_book);
        header("location: add_admin.php");
    } else {
        echo ($response);
        header("location: add_admin.php#failedToAddAdmin");
    }
}

if (isset($_POST['add_admin'])) {

    addAdmin();
}
