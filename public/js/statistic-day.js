$( document ).ready( function () {
    $("#sources").zmultiselect({
        live_text: "#live",
        placeholder: "Выберите источник",
        filter: true,
        filterPlaceholder: 'Фильтр...',
        filterResult: true,
        filterResultText: "Showed",
        selectedText: ['Выбрано','из'],
        selectAllText: ["Выбрать все", "Снять все"]
    });

    function build_row(row) {
        tr = $("<tr>");

        $.each(row, function(index, value) {
            tr.append($("<td>").text(value));
        });

        $("table#statistic tbody").append(tr);
    }


    $("#build").click(function () {

        date_start =  $("#date_start").val();
        date_end =  $("#date_end").val();
        sources = $("#sources").zmultiselect('getValue');
        work_type = $("#work_type").val();

        if (sources.length === 0 || date_start === "" || date_end === "") {
            alert("Заполните все поля.");
            return false;
        }

        $.each(sources, function(index, value) {
            url = "/api/statistic-day/";
            params = {
                "source": value,
                "work_type": work_type,
                "date_start": date_start,
                "date_end": date_end
            };

            $.ajax({
                url: url,
                type: 'get',
                dataType: 'json',
                async: false,
                data: params,
                success: function(data) {
                    build_row(data);
                }
            });
        });
    });
});