function iso8601string(date){
    let date_year = date.getFullYear();
    let date_month = ("0"+(date.getMonth()+1)).slice(-2);
    let date_day = ("0"+date.getDate()).slice(-2);
    return date_year + '-' + date_month + '-' + date_day;
}

function days_two_date(date2,date1){
    return (date2-date1)/86400000;
}
