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
    // init welcome message.
    $.getJSON("/user/get/userdata",function(data){
        $("#user-welcome").text("ようこそ、"+data.body.username+"さん");
        $("#basepoint-setting").val(data.body.basepoint);
        $("#current-balance").text("現在の残高は"+data.body.balance+"です");
    });

    // init summary table & data table
    $.getJSON("/book/read/simple-summary-data",function(data){
        // all data
        $("#income-recent-month").text(data.body.incomeall);
        $("#outlay-recent-month").text(data.body.outlayall);
        $("#sum-of-month").text(data.body.incomeall - data.body.outlayall);

        // today data
        let total_of_date = function(d,dt){
            let all_income = d.filter(itm => {return itm.incometype == true && itm.recordDate == dt;});
            let all_outlay = d.filter(itm => {return itm.incometype != true && itm.recordDate == dt;});
            let total_income = all_income.reduce((acc,x) => acc + x.val,0);
            let total_outlay = all_outlay.reduce((acc,x) => acc + x.val,0);
            return {income: total_income, outlay: total_outlay};
        };
        let today = iso8601string(new Date());
        let today_total = total_of_date(data.body.data,today);
        $("#income-today").text(today_total.income);
        $("#outlay-today").text(today_total.outlay);
        $("#sum-of-today").text(today_total.income - today_total.outlay);

        // recent data table
        $('#recent-data-tbody').empty();
        data.body.data.forEach(function(itm){
            let incometype = "";
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

        // pie graph initialization
        $("#income-pie-graph").empty();
        $("#outlay-pie-graph").empty();
        let breakdown_to_graphdata = function(d){
            let rtn = {values: [],labels: []};
            for(let key in d){
                rtn.labels.push(key);
                rtn.values.push(d[key]);
            }
            return rtn;
        };
        let income_pie_data = breakdown_to_graphdata(data.body.incomebreakdown);
        let outlay_pie_data = breakdown_to_graphdata(data.body.outlaybreakdown);
        if(income_pie_data.values.length != 0){
            let income_pie = [{
                values: income_pie_data.values,
                labels: income_pie_data.labels,
                type: 'pie'
            }];
            Plotly.newPlot('income-pie-graph',income_pie,{title: "収入内訳",font: {size: 18},automargin: true},{responsive: true});
        }else{
            $("#income-pie-graph").append('<p class="text-center">データがありません</p>');
        }
        if(outlay_pie_data.values.length != 0){
            let outlay_pie = [{
                values: outlay_pie_data.values,
                labels: outlay_pie_data.labels,
                type: 'pie'
            }];
            Plotly.newPlot('outlay-pie-graph',outlay_pie,{title: "支出内訳",font: {size: 18},automargin: true},{responsive: true});
        }else{
            $("#outlay-pie-graph").append('<p class="text-center">データがありません</p>');
        }

        let daily_date_to_graphdata = function(d){
            var rtn = {x:[],y:[]};
            for(let key in d){
                let year = String(key).slice(0,4);
                let month = String(key).slice(4,6);
                let date = String(key).slice(6,8);
                rtn.x.push(year + "-" + month + "-" + date);
                rtn.y.push(d[key]);
            }
            return rtn;
        };

        var daily_income_data = daily_date_to_graphdata(data.body.incomedaily);
        var daily_outlay_data = daily_date_to_graphdata(data.body.outlaydaily);
        var daily_graph_income_data = [{
            x: daily_income_data.x,
            y: daily_income_data.y,
            name: "収入",
            type: "bar"
        }];
        var daily_graph_outlay_data = [{
            x: daily_outlay_data.x,
            y: daily_outlay_data.y,
            name: "支出",
            type: "bar",
            marker: {color: "red"}
        }];
        Plotly.newPlot('daily-income-data-graph',
                       daily_graph_income_data,
                       {
                           barmode: "group",
                           font: {size: 18},
                           xaxis: {dtick: 24*60*60*1000},
                           yaxis: {title: "合計出費"},
                       },{responsive: true});
        Plotly.newPlot('daily-outlay-data-graph',
                       daily_graph_outlay_data,
                       {
                           barmode: "group",
                           font: {size: 18},
                           xaxis: {dtick: 24*60*60*1000},
                           yaxis: {title: "合計出費"}
                       },{responsive: true});
    });
}

function setup_userwelcome_board(){
    //preparation of select options
    for(let d = 1;d <= 31;d++){
        $("#basepoint-setting").append('<option value="' + d + '">' + d + "</option>");
    }

    update_user_data();
}

function set_basepoint(newday){
    $.get("/user/update/basepoint/simple/" + newday);
    update_user_data();
}

function book_write(){
        if($("#add-input-form").get(0).reportValidity() == true){
            // disable button when sending data
            let thisbutton = $(this);
            thisbutton.attr("disabled",true);

            // read values from input/select
            let dataname = $("#money-data-name").val();
            let date = $("#date-of-data").val();
            let typeisincome = false;
            if($("#type-of-input").val() != "outlay"){
                typeisincome = true;
            }
            let amount = $("#amount-of-money").val();
            let cate = $("#cate-input").val();
            let comment = $("#comment-input").val();

            // build object to send data
            let data = {
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
                    $("#add-new-modal").modal('hide');
                }
            });
        }else{
            console.log("Required form is not filled out.");
        }
}

window.onload = function() {
    setup_init_addmodal_date();
    setup_userwelcome_board();

    $("#type-of-input").change(update_allmodal_detalist);

    $("#basepoint-setting").change(function(){
        set_basepoint($(this).val());
    });

    $("button#add").click(book_write);
};
