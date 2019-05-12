function set_current_data(){
    $.getJSON("/user/get/userdata",function(data){
        $("#username").val(data.body.username);
        $("#userbalance").val(data.body.balance);
    });
}

window.onload = function(){
    set_current_data();

    $("button#userdata-btn").click(function(){
        let newval = $("#userbalance").val();
        var data = {
            val: newval
        };
        $.ajax({
                type: "post",
                url: "/user/update/balance",
                data: JSON.stringify(data),
                contentType: 'application/json',
                dataType: "json",
                success: function(jsondata){
                    if(jsondata.code == 0){
                        console.log("No error reported.");
                    }else{
                        alert("不正な入力によりデータは記録されませんでした。\n入力内容をご確認ください。");
                        console.log(jsondata);
                    }
                },
                error: function(){
                    console.log("send error");
                    alert("サーバーへのデータ送信時に問題が発生しました。\nページをリロードしてやりなおしてください。\n改善しない場合はサーバー管理者へお問い合わせください。");
                },
                complete: function(){
                    set_current_data();
                }
            });
    });

    $("button#password-btn").click(function(){
        let newpass = $("#password").val();
        var data = {
            val: newpass
        };
        $.ajax({
                type: "post",
                url: "/user/update/password",
                data: JSON.stringify(data),
                contentType: 'application/json',
                dataType: "json",
                success: function(jsondata){
                    if(jsondata.code == 0){
                        console.log("No error reported.");
                    }else{
                        alert("不正な入力によりデータは記録されませんでした。\n入力内容をご確認ください。");
                        console.log(jsondata);
                    }
                },
                error: function(){
                    console.log("send error");
                    alert("サーバーへのデータ送信時に問題が発生しました。\nページをリロードしてやりなおしてください。\n改善しない場合はサーバー管理者へお問い合わせください。");
                },
                complete: function(){
                    set_current_data();
                }
            });
    });
}
