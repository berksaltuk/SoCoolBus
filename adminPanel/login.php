<?php
//you have the attributes in the config

//session_start(); should always be placed at the top of the document
session_start();

//$_POST is a special array that stores data received from an HTTP POST request to a particular webpage 
// HTTP POST data string is parsed and added to the $_POST array, so that it's easier for developers to use for common tasks, like handling HTML form submissions.

//_SESSION data is not dependent on a particular page or HTTP request;
// its data is persisted across pages and is typically used for things like keeping track of account data

function logon()
{
    //value is stored in name, key is logon_name
    $username = $_POST['login_name']; //customer names serve as logins
    $password = $_POST['login_password'];  // and their id’s serve as passwords

    $payload = json_encode(array("username" => $username, "password" => $password));


    $ch = curl_init('https://socoolbus.herokuapp.com/adminPanel/adminLogin');
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
        $_SESSION['who_are_you'] = $username;
        $_SESSION['token'] = $json["token"];
        header("location: dashboard.php");
    } else {
        header("location: index.php?error=wrong_name_or_password");
        exit();
    }
}

if (isset($_POST['IS_SUBMITTED'])) {

    logon();
}
