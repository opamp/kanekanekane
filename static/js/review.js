var current_data;
var editing_data_id;

function find_data(id){
    var data = current_data.body.data;
    return data.find(function(x){
        return x.id == id;
    });
}

function find_data_index(id){
    var data = current_data.body.data;
    return data.findIndex(function(x){
        return x.id == id;
    });
}

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

function start_editor(id){
    var target_data = find_data(id);
    if(typeof target_data === "undefined"){
        alert("指定データが見つかりません。\nページをリロードしてやり直してください。\n改善されない場合管理者へ報告してください。\n[id = "+id+"]");
    }else{
        editing_data_id = id;
        $("#money-data-name").val(target_data.title);
        $("#date-of-data").val(target_data.recordDate);
        if(target_data.incometype === true){
            $("#type-of-input").val("income");
        }else{
            $("#type-of-input").val("outlay");
        }
        $("#amount-of-money").val(target_data.val);
        $("#cate-input").val(target_data.category);
        $("#comment-input").val(target_data.comment);
        $("#editor-modal").modal("show");
    }
}

function finish_editor(){
    $("#money-data-name").val("");
    $("#date-of-data").val("");
    $("#type-of-input").val("");
    $("#amount-of-money").val("");
    $("#cate-input").val("");
    $("#comment-input").val("");
    editing_data_id = -1;
    review_data();
    $("#editor-modal").modal("hide");
}

function build_data_table(data){
    current_data = data;
    $('#data-tbody').empty();
    data.body.data.forEach(function(itm){
        var incometype = "";
        if(itm.incometype == true){
            incometype = "収入";
        }else{
            incometype = "支出";
        }
        $('#data-tbody').append(
            $("<tr></tr>")
                .append($("<td></td>").text(itm.recordDate))
                .append($("<td></td>").text(itm.title))
                .append($("<td></td>").text(incometype))
                .append($("<td></td>").text(itm.category))
                .append($("<td></td>").text(itm.val))
                .append($("<td></td>").text(itm.comment))
                .append($("<td></td>").append('<button onclick="start_editor('+itm.id+');" type="button" class="btn btn-warning btn-sm">Edit</button>'))
        );
    });
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

function edit_data(){
    var target_data = find_data(editing_data_id);
    if($("#editor-form").get(0).reportValidity() == true && typeof target_data !== "undefined"){
        $("#edit").attr("disabled",true);
        $("#delete").attr("disabled",true);

        //read data
        var dataname = $("#money-data-name").val();
        var date = $("#date-of-data").val();
        var typeisincome = false;
        if($("#type-of-input").val() != "outlay"){
            typeisincome = true;
        }
        var amount = $("#amount-of-money").val();
        var cate = $("#cate-input").val();
        var comment = $("#comment-input").val();

        var data = {
            id: target_data.id,
            name: dataname,
            date: date,
            incometype: typeisincome,
            amount: amount,
            category: cate,
            comment: comment
        };

        $.ajax({
            type: "post",
            url: "/book/rewrite",
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
                $("#edit").attr("disabled",false);
                $("#delete").attr("disabled",false);
                finish_editor();
            }
        });
    }else{
        console.log("Required form is not filled out.");
    }
}

function delete_data(){
    var target_data = find_data(editing_data_id);
    if($("#editor-form").get(0).reportValidity() == true && typeof target_data !== "undefined"){
        $("#edit").attr("disabled",true);
        $("#delete").attr("disabled",true);
        var data = {
            ids: [target_data.id]
        };
        $.ajax({
            type: "post",
            url: "/book/eliminate",
            data: JSON.stringify(data),
            contentType: 'application/json',
            dataType: "json",
            success: function(jsondata){
                if(jsondata.code == 0){
                    console.log("No error reported.");
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
                $("#edit").attr("disabled",false);
                $("#delete").attr("disabled",false);
                finish_editor();
            } 
        });
    }else{
    }
    finish_editor();
}

window.onload = function(){
    editing_data_id = -1;
    set_this_month_date();
    $("button#range-select-button").click(review_data);
    $("button#edit").click(edit_data);
    $("button#delete").click(delete_data);
}
