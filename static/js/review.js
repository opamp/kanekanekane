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

function build_graph(data){
    var income_data = [];
    var outlay_data = [];

    data.body.data.forEach(function(itm){
        let catename = itm.category;
        if(itm.incometype == true){
            if(income_data.findIndex(function(elm){return elm.name == catename;}) < 0){
                income_data.push({
                    x: [],
                    y: [],
                    name: catename,
                    type: "bar"
                });
            }
        }else{
            if(outlay_data.findIndex(function(elm){return elm.name == catename;}) < 0){
                outlay_data.push({
                    x: [],
                    y: [],
                    name: catename,
                    type: "bar"
                });
            }
        }
    });

    var wdate = new Date($("#range-selector-from-input").val());
    var todate = new Date($("#range-selector-to-input").val());
    while(wdate.getTime() <= todate.getTime()){
        income_data.forEach(function(itm){
            itm.x.push(iso8601string(wdate));
            let target_itms = data.body.data.filter(function(elm){
                return elm.category == itm.name && elm.incometype == true &&
                    (new Date(elm.recordDate)).getTime() == wdate.getTime();
            });
            let sum = 0;
            target_itms.forEach(function(elm){sum += elm.val;});
            itm.y.push(sum);
        });

        outlay_data.forEach(function(itm){
            itm.x.push(iso8601string(wdate));
            let target_itms = data.body.data.filter(function(elm){
                return elm.category == itm.name && elm.incometype != true &&
                    (new Date(elm.recordDate)).getTime() == wdate.getTime();
            });
            let sum = 0;
            target_itms.forEach(function(elm){sum += elm.val;});
            itm.y.push(sum);
        });

        wdate.setDate(wdate.getDate()+1);
    }

    Plotly.newPlot("income-change-graph-area",
                   income_data,
                   {barmode: "stack",
                    font: {size: 18},
                    xaxis: {tickmode: "linear",
                            dtick: 24*60*60*1000}
                   });

    Plotly.newPlot("outlay-change-graph-area",
                   outlay_data,
                   {barmode: "stack",
                    font: {size: 18},
                    xaxis: {tickmode: "linear",
                            dtick: 24*60*60*1000}
                   });
    return [income_data,outlay_data];
}

function build_table(data){
    let sum_income = 0;
    let sum_outlay = 0;
    data.body.data.forEach(function(itm){
        if(itm.incometype == true){
            sum_income += itm.val;
        }else{
            sum_outlay += itm.val;
        }
    });
    let days = ((new Date($("#range-selector-to-input").val())) - (new Date($("#range-selector-from-input").val())))/86400000;
    $("#income-sum").text(sum_income);
    $("#income-sum-day").text(Math.round(sum_income/days));
    $("#outlay-sum").text(sum_outlay);
    $("#outlay-sum-day").text(Math.round(sum_outlay/days));
    $("#diff").text(sum_income - sum_outlay);
    $("#diff-day").text(Math.round(sum_income/days - sum_outlay/days));
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
                    build_graph(jsondata);
                    build_table(jsondata);
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
            id: target_data.id
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

function save_data_csv(){
    var text = "id,title,date,value,comment,cate_id,incometype,category_name\n";
    current_data.body.data.forEach(function(itm){
        if(itm.incometype == true){
            text += itm.id
                + ","
                + itm.title
                + ","
                + itm.recordDate
                + ","
                + itm.val
                + ","
                + itm.comment
                + ","
                + itm.cateid
                + ",true,"
                + itm.category
                + "\n";
        }else{
            text += itm.id
                + ","
                + itm.title
                + ","
                + itm.recordDate
                + ","
                + itm.val
                + ","
                + itm.comment
                + ","
                + itm.cateid
                + ",false,"
                + itm.category
                + "\n";
        }
    });
    var blob = new Blob([text]);
    $("#dl-btn-area").empty();
    $("#dl-btn-area").append('<a href="'+window.URL.createObjectURL(blob)+'" download="kanekanekane_data.csv">Download here</a>');
}

function save_data_json(){
    var text = JSON.stringify(current_data.body.data);
    var blob = new Blob([text]);
    $("#dl-btn-area").empty();
    $("#dl-btn-area").append('<a href="'+window.URL.createObjectURL(blob)+'" download="kanekanekane_data.json">Download here</a>');
}

window.onload = function(){
    editing_data_id = -1;
    set_this_month_date();
    $("button#range-select-button").click(review_data);
    $("button#edit").click(edit_data);
    $("button#delete").click(delete_data);
    $("button#data-gen-btn-csv").click(save_data_csv);
    $("button#data-gen-btn-json").click(save_data_json);
}
