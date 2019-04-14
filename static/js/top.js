/*
function setup_init_date(){
    var today = new Date();
    var today_year = today.getFullYear();
    var today_month = ("0"+(today.getMonth()+1)).slice(-2);
    var today_day = ("0"+today.getDate()).slice(-2);
    document.getElementById("end-date").value = today_year + '-' + today_month + '-' + today_day;
    document.getElementById("end-date").max = today_year + '-' + today_month + '-' + today_day;

    var onemonthbefore = new Date();
    onemonthbefore.setMonth(onemonthbefore.getMonth()-1);
    var onemonthbefore_year = onemonthbefore.getFullYear();
    var onemonthbefore_month = ("0"+(onemonthbefore.getMonth()+1)).slice(-2);
    var onemonthbefore_day = ("0"+onemonthbefore.getDate()).slice(-2);
    document.getElementById("start-date").value = onemonthbefore_year + '-' + onemonthbefore_month + '-' + onemonthbefore_day;
    set_max_of_start();
};

function set_max_of_start(){
    document.getElementById("start-date").max = document.getElementById("end-date").value;
}
*/
window.onload = function() {
    //setup_init_date();
};
