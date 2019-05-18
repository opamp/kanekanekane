function signup(){
    if($("#signup-form").get(0).reportValidity() == true){
        $("#signup-btn").attr("disabled",true);

        var data = {
            name: $("#inputUsername").val(),
            password: $("#inputPass").val(),
            balance: Number($("#inputInitB").val())
        };

        $.ajax({
            type: "post",
            url: "/signup",
            data: JSON.stringify(data),
            contentType: 'application/json',
            dataType: "json",
            success: function(jsondata){
                if(jsondata.code == 0){
                    console.log("No error reported.");
                    alert("ユーザー登録が完了しました。\nログインしてご利用ください。");
                    window.location.href = "/signin";
                }else if(jsondata.code == 1){
                    alert("パスワードが短すぎます");
                    console.log(jsondata);
                }else if(jsondata.code == 2){
                    alert("すでにユーザーが存在します");
                    console.log(jsondata);
                }else if(jsondata.code == 3){
                    alert("ユーザーは登録できましたが、残高設定に失敗しました。ログイン後手動で再設定してください");
                    console.log(jsondata);
                }else{
                    alert("サーバーでエラーが発生しました。\nページをリロードしてやり直してください。\n改善しない場合はサーバー管理者へお問い合わせください。");
                    console.log(jsondata);
                }
            },
            error: function(){
                console.log("send error");
                alert("サーバーへのデータ送信時に問題が発生しました。\nページをリロードしてやりなおしてください。\n改善しない場合はサーバー管理者へお問い合わせください。");
            },
            complete: function(){
                $("#signup-btn").attr("disabled",false);
            }
        });
    }
}

window.onload = function(){
    $("#signup-btn").click(signup);
};
