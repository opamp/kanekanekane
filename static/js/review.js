function iso8601string(date){
    var date_year = date.getFullYear();
    var date_month = ("0"+(date.getMonth()+1)).slice(-2);
    var date_day = ("0"+date.getDate()).slice(-2);
    return date_year + '-' + date_month + '-' + date_day;
}

function set_this_month_date(){
    var today = iso8601string(new Date());
    $("#range-selector-to-input").val(today);
    $.getJSON("/user/get/basepoint-date",function(rtndata){
        let year = rtndata.body[0];
        let month = ("0"+rtndata.body[1]).slice(-2);
        let day = ("0"+rtndata.body[2]).slice(-2);
        $("#range-selector-from-input").val(year + "-" + month + "-" + day);
    });
}

function set_this_year_date(){
    var today = new Date();
    $("#range-selector-to-input").val(iso8601string(today));

    var fromday = today;
    fromday.setMonth(0);
    fromday.setDate(1);
    $("#range-selector-from-input").val(iso8601string(fromday));
}

function set_one_year_date(){
    var today = new Date();
    $("#range-selector-to-input").val(iso8601string(today));

    var fromday = today;
    fromday.setFullYear(fromday.getFullYear()-1);
    $("#range-selector-from-input").val(iso8601string(fromday));
}

function set_one_month_date(){
    var today = new Date();
    $("#range-selector-to-input").val(iso8601string(today));

    var fromday = today;
    fromday.setMonth(fromday.getMonth()-1);
    $("#range-selector-from-input").val(iso8601string(fromday));
}

function build_data_table(data){
    console.log(data);
}

function review_data(){
    if($("#range-selector-form").get(0).reportValidity()==true){
        var data = {
            fromdate: $("#range-selector-from-input").val(),
            todate: $("#range-selector-to-input").val()
        };

        $.ajax({
            type: "post",
            url: "/book/read",
            data: JSON.stringify(data),
            contentType: 'application/json',
            dataType: "json",
            success: function(jsondata){
                if(jsondata.code == 0){
                    console.log("No error reported.");
                    build_data_table(jsondata);
                }else{
                    alert("サーバーエラーが発生しました。");
                    console.log(jsondata);
                }
            },
            error: function(){
                console.log("send error");
                alert("サーバーへのデータ送信時に問題が発生しました。\nページをリロードしてやりなおしてください。\n改善しない場合はサーバー管理者へお問い合わせください。");
            },
            complete: function(){
            }
        });
    }else{
        console.log("Required form is not filled out.");
    }
}

window.onload = function(){
    set_this_month_date();
    $("button#range-select-button").click(review_data);
}
