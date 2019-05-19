var current_data;
var editing_data_id;

function find_data(id){
    let data = current_data.body.data;
    return data.find(function(x){
        return x.id == id;
    });
}

function find_data_index(id){
    let data = current_data.body.data;
    return data.findIndex(function(x){
        return x.id == id;
    });
}

function update_allmodal_detalist(){
    let datalisttype = $("#type-of-input").val();
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

function set_this_month_date(){
    let today = iso8601string(new Date());
    $("#range-selector-to-input").val(today);
    $.getJSON("/user/get/basepoint-date",function(rtndata){
        let year = rtndata.body[0];
        let month = ("0"+rtndata.body[1]).slice(-2);
        let day = ("0"+rtndata.body[2]).slice(-2);
        $("#range-selector-from-input").val(year + "-" + month + "-" + day);
    });
}

function set_this_year_date(){
    let today = new Date();
    $("#range-selector-to-input").val(iso8601string(today));

    let fromday = today;
    fromday.setMonth(0);
    fromday.setDate(1);
    $("#range-selector-from-input").val(iso8601string(fromday));
}

function set_one_year_date(){
    let today = new Date();
    $("#range-selector-to-input").val(iso8601string(today));

    let fromday = today;
    fromday.setFullYear(fromday.getFullYear()-1);
    $("#range-selector-from-input").val(iso8601string(fromday));
}

function set_one_month_date(){
    let today = new Date();
    $("#range-selector-to-input").val(iso8601string(today));

    let fromday = today;
    fromday.setMonth(fromday.getMonth()-1);
    $("#range-selector-from-input").val(iso8601string(fromday));
}

function start_editor(id){
    let target_data = find_data(id);
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
        let incometype = "";
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
    // pie graph
    let income_pie_data = {values: [],labels: [],type: "pie"};
    let outlay_pie_data = {values: [],labels: [],type: "pie"};

    data.body.data.forEach(function(itm){
        let category_equal = function(i){return i == itm.category;};
        if(itm.incometype == true){
            let indexnum = income_pie_data.labels.findIndex(category_equal);
            if(indexnum >= 0){
                income_pie_data.values[indexnum] += itm.val;
            }else{
                income_pie_data.labels.push(itm.category);
                income_pie_data.values.push(itm.val);
            }
        }else{
            let indexnum = outlay_pie_data.labels.findIndex(category_equal);
            if(indexnum >= 0){
                outlay_pie_data.values[indexnum] += itm.val;
            }else{
                outlay_pie_data.labels.push(itm.category);
                outlay_pie_data.values.push(itm.val);
            }
        }
    });

    $("#income-pie-graph").empty();
    $("#outlay-pie-graph").empty();
    if(income_pie_data.labels.length > 0){
        Plotly.newPlot("income-pie-graph",[income_pie_data],{font: {size: 18},automargin: true},{responsive: true});
    }else{
        $("#income-pie-graph").append('<p class="text-center">データがありません</p>');
    }
    if(outlay_pie_data.labels.length > 0){
        Plotly.newPlot("outlay-pie-graph",[outlay_pie_data],{font: {size: 18},automargin: true},{responsive: true});
    }else{
        $("#outlay-pie-graph").append('<p class="text-center">データがありません</p>');
    }

    // stacked bar graph
    let income_data = [];
    let outlay_data = [];
    let wdate = new Date($("#range-selector-from-input").val());
    let todate = new Date($("#range-selector-to-input").val());

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

    wdate = new Date($("#range-selector-from-input").val());
    todate = new Date($("#range-selector-to-input").val());
    let change_graph_layout = {};
    if(days_two_date(todate,wdate) < 6){
        change_graph_layout = {
            barmode: "stack",
            font: {size: 18},
            xaxis: {
                dtick: "D",
                tick0: iso8601string(wdate),
                range: [iso8601string(wdate),iso8601string(todate)]}
        };
    }else{
        change_graph_layout = {
            barmode: "stack",
            font: {size: 18},
            xaxis: {
                tick0: iso8601string(wdate),
                range: [iso8601string(wdate),iso8601string(todate)]}
        };
    }
    $("#income-change-graph-area").empty();
    if(income_data.length > 0){
        Plotly.newPlot("income-change-graph-area",
                       income_data,
                       change_graph_layout);
    }else{
        $("#income-change-graph-area").append('<p class="text-center">データがありません</p>');
    }

    $("#outlay-change-graph-area").empty();
    if(outlay_data.length > 0){
        Plotly.newPlot("outlay-change-graph-area",
                       outlay_data,
                       change_graph_layout);
    }else{
        $("#outlay-change-graph-area").append('<p class="text-center">データがありません</p>');
    }

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
    let days = days_two_date(new Date($("#range-selector-to-input").val()),new Date($("#range-selector-from-input").val()));
    $("#income-sum").text(sum_income);
    $("#income-sum-day").text(Math.round(sum_income/days));
    $("#outlay-sum").text(sum_outlay);
    $("#outlay-sum-day").text(Math.round(sum_outlay/days));
    $("#diff").text(sum_income - sum_outlay);
    $("#diff-day").text(Math.round(sum_income/days - sum_outlay/days));
}

function review_data(){
    if($("#range-selector-form").get(0).reportValidity()==true){
        let data = {
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
    let target_data = find_data(editing_data_id);
    if($("#editor-form").get(0).reportValidity() == true && typeof target_data !== "undefined"){
        $("#edit").attr("disabled",true);
        $("#delete").attr("disabled",true);

        //read data
        let dataname = $("#money-data-name").val();
        let date = $("#date-of-data").val();
        let typeisincome = false;
        if($("#type-of-input").val() != "outlay"){
            typeisincome = true;
        }
        let amount = $("#amount-of-money").val();
        let cate = $("#cate-input").val();
        let comment = $("#comment-input").val();

        let data = {
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
    let target_data = find_data(editing_data_id);
    if($("#editor-form").get(0).reportValidity() == true && typeof target_data !== "undefined"){
        $("#edit").attr("disabled",true);
        $("#delete").attr("disabled",true);
        let data = {
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
    let text = "id,title,date,value,comment,cate_id,incometype,category_name\n";
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
    let blob = new Blob([text]);
    $("#dl-btn-area").empty();
    $("#dl-btn-area").append('<a href="'+window.URL.createObjectURL(blob)+'" download="kanekanekane_data.csv">Download here</a>');
}

function save_data_json(){
    let text = JSON.stringify(current_data.body.data);
    let blob = new Blob([text]);
    $("#dl-btn-area").empty();
    $("#dl-btn-area").append('<a href="'+window.URL.createObjectURL(blob)+'" download="kanekanekane_data.json">Download here</a>');
}

window.onload = function(){
    editing_data_id = -1;
    set_this_month_date();
    update_allmodal_detalist();
    $("button#range-select-button").click(review_data);
    $("#type-of-input").change(update_allmodal_detalist);
    $("button#edit").click(edit_data);
    $("button#delete").click(delete_data);
    $("button#data-gen-btn-csv").click(save_data_csv);
    $("button#data-gen-btn-json").click(save_data_json);
}
