function setup_init_addmodal_date(){
    var today = new Date();
    var today_year = today.getFullYear();
    var today_month = ("0"+(today.getMonth()+1)).slice(-2);
    var today_day = ("0"+today.getDate()).slice(-2);
    $("#date-of-data").val(today_year + '-' + today_month + '-' + today_day);
    $("#date-of-data").attr("max",today_year + '-' + today_month + '-' + today_day);
}

window.onload = function() {
    setup_init_addmodal_date();

    $("button#add").click(function() {
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
        console.log(data); // for checking

        $.ajax({
            type: "post",
            url: "/book/write",
            data: JSON.stringify(data),
            contentType: 'application/json',
            dataType: "json",
            success: function(jsondata){
                console.log("success pushing");
            },
            error: function(){
                console.log("send error");
            },
            complete: function(){
                thisbutton.attr("disabled",false);
            }
        });
    });
};
