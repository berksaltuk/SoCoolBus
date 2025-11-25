<?php
session_start();

if ($_SESSION['who_are_you'] == null) {
    header("Location: index.php");
}

?>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.2/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-Zenh87qX5JnK2Jl0vWa8Ck2rdkQ2Bzep5IDxbcnCeuOxjzrPF/et3URy9Bv1WTRi" crossorigin="anonymous">
    <title>Welcome User</title>
</head>

<body>
    <div class="vh-100 d-flex flex-column justify-content-center align-items-center">
        <nav class="navbar navbar-expand-lg navbar-light bg-info justify-content-between w-100">
            <span class="text-light mr-3"> Hoşgeldin 
                <?php echo  $_SESSION['who_are_you']; ?>
            </span>
            <a href="finish_session.php"><span class="btn btn-secondary">Çıkış Yap</span></a>
        </nav>
        <div class="card text-center w-100 h-100 all">
            <div class="card-header">
                <ul class="nav nav-tabs card-header-tabs">
                    <li class="nav-item">
                        <a href="#" class="nav-link active" id="firstLink">Ana Sayfa</a>
                    </li>
            </div>
            <div class="card-body p-3">
                <div class="justify-content-between">
                    <a href="approve_document.php"><span class="btn btn-secondary">Doküman Onayla</span></a>
                    <a href="approve_school.php"><span class="btn btn-secondary">Okul Onayla</span></a>
                    <a href="approve_companyAdmin.php"><span class="btn btn-secondary">Şirket Yöneticisi
                            Onayla</span></a>
                    <a href="approve_SchoolAdmin.php"><span class="btn btn-secondary">Okul Yöneticisi Onayla</span></a>
                    <a href="approve_company.php"><span class="btn btn-secondary">Şirket Onayla</span></a>
                    <a href="add_admin.php"><span class="btn btn-secondary">Admin Ekle</span></a>
                    </span></a>
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