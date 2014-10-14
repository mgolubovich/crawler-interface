$(document).foundation();

$(document).ready(function(){
    $(".switch-ajax").children("label").click(function(){
        switcher = $(this).prev("input");
        model_id = switcher.attr("name").split("_");
        model = model_id[0];
        id = model_id[1];
        //Мы получаем текущее состояние на момент клика. Меняем "on" и "off" местати, чтобы получить значение в которое переведется переключатель
        active = switcher.is(":checked") ? "off" : "on";
        url = ["/api/switch", model, id, active];
        url = url.join("/");

        result = true;

        $.ajax({
            url: url,
            type: 'get',
            dataType: 'json',
            async: false,
            success: function(data) {
                if (data.result != 'success') {
                    alert(data.result);
                    result = false;
                }
            }
        });

        return result;
    });
});