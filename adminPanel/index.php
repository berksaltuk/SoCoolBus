<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link type="text/css" rel="stylesheet" href="extra.css">

    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css"
        integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous">
    <title>ServisYolum Admin Panel</title>
</head>

<body>

    <div class="container  d-flex justify-content-center align-items-center vh-100 w-100">
        <div class="text-center rounded-left col-sm-4 h-50 d-flex flex-column justify-content-center align-items-center"
            id="title_part">
            <h2 class="text-black">Servis yolum admin panele hoşgeldiniz!</h2>
        </div>
        <div class="p-7  col-sm-6 h-80 d-flex justify-content-center align-items-center rounded-right" id="main_part">
            <div class="d-flex justify-content-center ">
                <form method="POST" action="login.php" onsubmit="return checkLogin()">
                    <p class="wrong_input">İsim ve şifre eşleşmemektedir!</p>
                    <div class="form-group row">
                        <label for="name_place" class="form-label">Kullanıcı ismi: </label>
                        <div class="col-sm-10">
                            <input type="text" class="form-control" id="name_place" name="login_name"
                                placeholder="Lütfen kullanıcı isminizi giriniz">
                            <p class="isBlank">Bu alan boş bırakılamaz!</p>
                        </div>
                    </div>
                    <div class="form-group row">
                        <label for="password_place" class="form-label">Şifre</label>
                    </div>
                    <div class="form-group row">

                        <div class="col-sm-10">
                            <input type="password" class="form-control" id="password_place" name="login_password"
                                placeholder="Lütfen şifrenizi giriniz">
                            <p class="isBlank">Bu alan boş bırakılamaz!</p>

                        </div>
                    </div>
                    <div class="mb-3 form-check">
                        <button type="submit" class="btn btn-primary" name="IS_SUBMITTED" value="IS_SUBMITTED">Giriş
                            yap</button>
                    </div>

                </form>
            </div>
            <?php
            if (isset($_GET["error"])) {
                if ($_GET["error"] == 'wrong_name_or_password') {
                    echo "<div class='alert alert-danger alert-dismissible fade show' role='alert'>
                    wrong name or password
                    <button type='button' class='close' data-dismiss='alert' aria-label='close_alert'>
                    <span aria-hidden='true'>&times;</span>
                    </button>
                    </div>";
                }
            }

            ?>
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

    <script>
    function checkLogin() {
        const get = document.getElementsByClassName("isBlank");
        let check = true;
        if (document.getElementById('name_place').value == "") {
            get[0].style.display = 'block';
            check = false;
        } else {
            get[0].style.display = 'none';
        }

        if (document.getElementById('password_place').value == "") {
            get[1].style.display = 'block';
            check = false;
        } else {
            get[1].style.display = 'none';
        }
        return check;
    }
    </script>

</body>

</html>