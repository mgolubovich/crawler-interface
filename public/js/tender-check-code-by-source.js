$('#check_code_by_source').click(function() { CheckSourceCode() });

function FindTenderBySourceCode(source_id, code_by_source) {
    $.ajaxSetup({ async: false });

    url = '/api/check-code-source/' + source_id + '/' + code_by_source;
    tender_id = 0;

    $.getJSON(url, function(data) {
        tender_id = data.result;
    });

    return tender_id;
}

function CheckSourceCode() {
    button = $('#check_code_by_source');
    if (button.hasClass('disabled')) { return false; }

    source_id = $('#tender_source_id').val();
    code_by_source = $('#tender_code_by_source').val();

    tender_id = FindTenderBySourceCode(source_id, code_by_source);
    if (tender_id > 0) {
        window.location.replace('/tenders/' + data.result + '/edit');
    } else {
        button.addClass("btn-orange").val("Тендер не найден");
        setTimeout(function(){ button.removeClass("btn-orange").val("Проверить"); }, 3000);
    }
}