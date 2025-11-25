<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.2/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-Zenh87qX5JnK2Jl0vWa8Ck2rdkQ2Bzep5IDxbcnCeuOxjzrPF/et3URy9Bv1WTRi" crossorigin="anonymous">
    <title> Onay Bekleyen Okullar <?php
                                    session_start();; ?></title>
</head>

<body>
    <div class="vh-100 d-flex flex-column justify-content-center align-items-center">
        <nav class="navbar navbar-expand-lg navbar-light bg-info justify-content-between w-100">
            <span class="text-light mr-3"> Merhaba
                <?php echo $_SESSION['who_are_you']; ?>
            </span>
            <a href="dashboard.php"><span class="btn btn-secondary">Ana Sayfa</span></a>
            <a href="finish_session.php"><span class="btn btn-secondary">Çıkış Yap</span></a>
        </nav>
        <div class="card text-center w-100 h-100 all">
            <div class="card-header">
                <ul class="nav nav-tabs card-header-tabs">
                    <li class="nav-item">
                        <a href="#" class="nav-link active" id="firstLink">Onay Bekleyen Okullar </a>
                    </li>
            </div>
            <div class="card-body p-3">
                <div class="justify-content-between">


                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>İsim</th>
                                <th>Adres</th>
                                <th>Okul tipi</th>
                                <th>Shift Sayısı</th>
                                <th>Servis Günleri</th>
                                <th>Giriş Zamanı</th>
                                <th>Çıkış Zamanı</th>
                                <th>Okul süresi</th>


                            </tr>
                        </thead>
                        <tbody>
                            <?php
                            $ch = curl_init('https://socoolbus.herokuapp.com/adminPanel/getUnapprovedSchools');
                            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

                            // execute!
                            $response = curl_exec($ch);
                            $httpcode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
                            // close the connection, release resources used
                            curl_close($ch);

                            // do anything you want with your response
                            $json = json_decode($response, true);
                            // mysqli_num_rows — Gets the number of rows in the result set
                            if (count($json) > 0) {

                                foreach ($json as $item) {
                                    echo "<tr>
                                    <td>" . $item['name'] . "</th>
                                    
                                    <td>" . $item['address'] . "</td>
                                    <td>" . implode(", ", $item['schoolType']) . "</th>
                                    
                                    <td>" . $item['shiftCount'] . "</td>
                                    <td>" . implode(", ", $item['serviceDays']) . "</th>          
                                    <td>" . $item['firstEntranceTime'] . "</td>
                                    <td>" . $item['firstExitTime'] . "</th>
                                    <td>" . $item['serviceTimeInMonths'] . "</td>
                                  

                                    <form method='POST' action='approveSchool_operation.php' class='form-inline'>
                                    <input type='hidden' name='approve_sch' value='" . $item['_id'] . "'>
                                    <td><button type='submit' value = 'approve' name = 'approve'><span class='btn btn-success'>Onayla</span> </td> 
                                    <input type='hidden' name='reject_sch' value='" . $item['_id'] . "'>
                                    <td><button type='submit' value = 'reject' name = 'reject'><span class='btn btn-danger'>Reddet</span> </td>   
                                    </form>
                                    </tr>";
                                }
                            } else {
                                echo "<tr>
                                <td colspan = 10>Onay bekleyen okul yok</td>
                                </tr>";
                            }
                            ?>
                        </tbody>
                    </table>


                </div>

            </div>
        </div>

    </div>
    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js"
        integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous">
    </script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"
        integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous">
    </script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"
        integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous">
    </script>

</body>

</html>