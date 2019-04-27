function iso8601string(date){
    var date;
    var date_year = date.getFullYear();
    var date_month = ("0"+(date.getMonth()+1)).slice(-2);
    var date_day = ("0"+date.getDate()).slice(-2);
    return date_year + '-' + date_month + '-' + date_day;
}

function update_allmodal_detalist(){
    var datalisttype = $("#type-of-input").val();
    $("#existingcates").empty();
    $.getJSON("/category/get/all",function(data){
        if(datalisttype == "outlay"){
            $.each(data.body.outlay,function(index,val){
                $("#existingcates").append('<option value="' + val + '">');
            });
        }else{
            $.each(data.body.income,function(index,val){
                $("#existingcates").append('<option value="' + val + '">');
            });
        }
    });
}

function setup_init_addmodal_date(){
    var today = iso8601string(new Date());
    $("#date-of-data").val(today);
    $("#date-of-data").attr("max",today);
    update_allmodal_detalist();
}

function clear_addmodal_input(){
    $("#add-input-form").get(0).reset();
    setup_init_addmodal_date();
}

function update_user_data(){
   //settings load from server DB.
    $.getJSON("/user/get/userdata",function(data){
        $("#user-welcome").text("ようこそ、"+data.body.username+"さん");
        $("#basepoint-setting").val(data.body.basepoint);
        $("#current-balance").text("現在の残高は"+data.body.balance+"です");
    });

    $.getJSON("/book/read/simple-summary-data",function(data){
        $("#income-recent-month").text(data.body.incomeall);
        $("#outlay-recent-month").text(data.body.outlayall);
        $("#sum-of-month").text(data.body.incomeall - data.body.outlayall);

        var today = iso8601string(new Date());
        var today_income = data.body.data.filter(itm => {return itm.incometype == true && itm.recordDate == today;});
        var today_outlay = data.body.data.filter(itm => {return itm.incometype != true && itm.recordDate == today;});
        var today_income_val = today_income.reduce((acc,x) => acc + x.val,0);
        var today_outlay_val = today_outlay.reduce((acc,x) => acc + x.val,0);
        $("#income-today").text(today_income_val);
        $("#outlay-today").text(today_outlay_val);
        $("#sum-of-today").text(today_income_val - today_outlay_val);

        $('#recent-data-tbody').empty();
        data.body.data.forEach(function(itm){
            var incometype = "";
            if(itm.incometype == true){
                incometype = "収入";
            }else{
                incometype = "支出";
            }
            $('#recent-data-tbody').append(
                $("<tr></tr>")
                    .append($("<td></td>").text(itm.recordDate))
                    .append($("<td></td>").text(itm.title))
                    .append($("<td></td>").text(incometype))
                    .append($("<td></td>").text(itm.category))
                    .append($("<td></td>").text(itm.val))
            );
        });

        var breakdown_to_graphdata = function(d){
            var rtn = {values: [],labels: []};
            for(let key in d){
                rtn.labels.push(key);
                rtn.values.push(d[key]);
            }
            return rtn;
        };
        var income_pie_data = breakdown_to_graphdata(data.body.incomebreakdown);
        var outlay_pie_data = breakdown_to_graphdata(data.body.outlaybreakdown);

        var income_pie = [{
            values: income_pie_data.values,
            labels: income_pie_data.labels,
            type: 'pie'
        }];
        var outlay_pie = [{
            values: outlay_pie_data.values,
            labels: outlay_pie_data.labels,
            type: 'pie'
        }];
        console.log(income_pie);
        Plotly.newPlot('income-pie-graph',income_pie);
        Plotly.newPlot('outlay-pie-graph',outlay_pie);
    });
}

function setup_userwelcome_board(){
    //preparation of select options
    for(var d = 1;d <= 31;d++){
        $("#basepoint-setting").append('<option value="' + d + '">' + d + "</option>");
    }

    update_user_data();
}

window.onload = function() {
    setup_init_addmodal_date();
    setup_userwelcome_board();

    $("#type-of-input").change(function(){
        update_allmodal_detalist();
    });

    $("#basepoint-setting").change(function(){
        var value = $(this).val();
        $.get("/user/update/basepoint/simple/" + value);
        update_user_data();
    });

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
                    update_user_data();
                }
            });
        }else{
            console.log("Required form is not filled out.");
        }
    });
};
