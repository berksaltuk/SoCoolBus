<?php
session_start();

$school_id_approve = $_POST['approve_sch'];
$school_id_reject = $_POST['reject_sch'];
$payload = "";

if (isset($_POST['approve'])) {
    $payload = json_encode(array("schoolAdminPhone" => $school_id_approve, "approve" => true));
} else if (isset($_POST['reject'])) {
    $payload = json_encode(array("schoolAdminPhone" => $school_id_approve, "approve" => false));
}

$ch = curl_init('https://socoolbus.herokuapp.com/adminPanel/approveOrRejectSchoolAdmin');
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
    header("location: approve_SchoolAdmin.php");
} else {
    echo ($response);
    header("location: approve_SchoolAdmin.php#failedToApproveOrReject");
}
