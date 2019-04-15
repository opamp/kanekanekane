function setup_init_addmodal_date(){
    var today = new Date();
    var today_year = today.getFullYear();
    var today_month = ("0"+(today.getMonth()+1)).slice(-2);
    var today_day = ("0"+today.getDate()).slice(-2);
    document.getElementById("date-of-data").value = today_year + '-' + today_month + '-' + today_day;
    document.getElementById("date-of-data").max = today_year + '-' + today_month + '-' + today_day;
}

window.onload = function() {
    setup_init_addmodal_date();
};
