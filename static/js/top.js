function setup_init_addmodal_date(){
    var today = new Date();
    var today_year = today.getFullYear();
    var today_month = ("0"+(today.getMonth()+1)).slice(-2);
    var today_day = ("0"+today.getDate()).slice(-2);
    $("#date-of-data").val(today_year + '-' + today_month + '-' + today_day);
    $("#date-of-data").attr("max",today_year + '-' + today_month + '-' + today_day);
}

function clear_addmodal_input(){
    $("#add-input-form").get(0).reset();
    setup_init_addmodal_date();
}

window.onload = function() {
    setup_init_addmodal_date();

    $("button#add").click(function() {
        if($("#add-input-form").get(0).reportValidity() == true){
            // disable button when sending data
            var thisbutton = $(this);
            thisbutton.attr("disabled",true);

            // read values from input/select
            var dataname = $("#money-data-name").val();
            var date = $("#date-of-data").val();
            var typeisincome = false;
            if($("#type-of-input").val() != "outlay"){
                typeisincome = true;
            }
            var amount = $("#amount-of-money").val();
            var cate = $("#cate-input").val();
            var comment = $("#comment-input").val();

            // build object to send data
            var data = {
                name: dataname,
                date: date,
                incometype: typeisincome,
                amount: amount,
                category: cate,
                comment: comment
            };

            $.ajax({
                type: "post",
                url: "/book/write",
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
                    thisbutton.attr("disabled",false);
                    clear_addmodal_input();
                }
            });
        }else{
            console.log("Required form is not filled out.");
        }
    });
};
