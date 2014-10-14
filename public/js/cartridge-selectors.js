( function( $ ) {
    var types = [];
    var selectors =[];
    var $this;
    var colors = [
        "EA4B40", "EF7800", "9E0E1A", "008D34", "34A9E1",
        "292B82", "541C72", "683A07", "6E6E6E", "E5007D",
        "8D7604", "014521", "004C70", "FBF4B2", "C6D431",
        "C99D65", "D9DADA", "EE95BF", "2B2B2B", "FCEA06"
    ];
    var type_color = [];
    var selector_tbody;

    var methods = {
        init: function () {
            $.ajaxSetup( { async: false } );
            $this = this;

            methods.main_control.apply();
            methods.init_selectors.apply();

            $('body').on('click', ".selector-edit", function() { methods.selector_edit($(this).attr("selector_id")); });
            $('body').on('click', ".selector-delete", function() { methods.selector_delete($(this).attr("selector_id")); methods.recalculate_priority(); });
            $('body').on('click', "#selector-add", function() { methods.selector_add($("#selector-types").val()); methods.recalculate_priority(); });

            $('body').on('change', ".selector_is_active", function() {
                $("#selector_is_active_" + $(this).attr("selector_id")).attr("class", $(this).val() == '1' ? "fi-check medium color-green" : "fi-x medium color-red");
            });

            $('body').on('change', ".selector_value_type", function() {
                value = $(this).val();
                $("#selector_value_type_" + $(this).attr("selector_id")).attr("style", "background-color: #" + type_color[value]).text(value);
            });
        },

        main_control: function() {
            $.getJSON( '/api/selector-types', function( data ) { types = data } );

            select = $( '<select />' , { id: "selector-types", class: "form-control" } );
            $.each( types, function( index, type ) {
                option = $( "<option />", { value: type, text: type } );
                type_color[type] = colors[index];
                select.append( option );
            });

            button = $( '<input />', { id: "selector-add", name: "add_selector", type: "button", value: "Добавить", class: "button postfix" } );

            control_wrapper = $( "<div />", { class: "row collapse" } );
            select_wrapper = $( "<div />", { class: "medium-9 columns" }).append(select);
            button_wrapper = $( "<div />", { class: "medium-3 columns end" }).append(button);

            control_wrapper.append(select_wrapper).append(button_wrapper);
            $this.append( control_wrapper );
        },

        selector_edit: function(select_id, open_modal) {
            open_modal = typeof open_modal == "undefined" ? true : open_modal;

            if (!$(".reveal-modal").is("#modal_" + select_id)) {
                modal = $("<div data-reveal class='reveal-modal selector-form' id='modal_" + select_id + "'></div>");

                select_regexp_mode  = methods.build_select(select_id, selectors[select_id]['regexp']['mode'], 4, true, 'regexp][mode', false, 4);
                input_regexp_patter = methods.build_input(select_id, selectors[select_id]['regexp']['pattern'], 4, true, 'regexp][pattern', false, 8);
                elements = {
                    mode: {columns: 3, element: {label: 4, columns: 8, html: select_regexp_mode}},
                    pattern: {columns: 5, element: {label: 2, columns: 10, html: input_regexp_patter}}
                };


                regexp = methods.build_multi_wrapper(elements, 'regexp');

                input_offset_start  = methods.build_input(select_id, selectors[select_id]['offset']['start'], 4, true, 'offset][start', false);
                input_offset_end    = methods.build_input(select_id, selectors[select_id]['offset']['end'], 4, true, 'offset][end', false);
                elements = {
                    start: {columns: 4, element: {label: 3, columns: 9, html: input_offset_start}},
                    end: {columns: 4, element: {label: 3, columns: 9, html: input_offset_end}}
                };
                offset = methods.build_multi_wrapper(elements, 'offset');


                select_value_type   = methods.build_select(select_id, selectors[select_id]['value_type'], 8, true, 'value_type');
                select_to_type      = methods.build_select(select_id, selectors[select_id]['to_type'], 8, true, 'to_type');
                select_is_active    = methods.build_select(select_id, selectors[select_id]['is_active'], 8, true, 'is_active');

                input_link_template = methods.build_input(select_id, selectors[select_id]['link_template'], 8, true, 'link_template');
                input_xpath         = methods.build_input(select_id, selectors[select_id]['xpath'], 8, true, 'xpath');
                input_css           = methods.build_input(select_id, selectors[select_id]['css'], 8, true, 'css');
                input_attr          = methods.build_input(select_id, selectors[select_id]['attr'], 8, true, 'attr');
                input_delimiter     = methods.build_input(select_id, selectors[select_id]['delimiter'], 8, true, 'delimiter');
                input_date_format   = methods.build_input(select_id, selectors[select_id]['date_format'], 8, true, 'date_format');
                input_js_code       = methods.build_input(select_id, selectors[select_id]['js_code'], 8, true, 'js_code');
                input_priority      = methods.build_input(select_id, selectors[select_id]['priority'], 8, true, 'priority');

                modal
                    .append(select_value_type)
                    .append(input_link_template)
                    .append(input_xpath)
                    .append(input_css)
                    .append(input_attr)
                    .append(input_delimiter)
                    .append(offset)
                    .append(regexp)
                    .append(input_date_format)
                    .append(input_js_code)
                    .append(input_priority)
                    .append(select_to_type)
                    .append(select_is_active)
                ;

                modal.append($('<a/>', {class: "close-reveal-modal selector-edit-close", select_id: select_id, html: "&#215;"}));
                $this.append(modal);

                $(".selector-form input").change(function() { $("span[selector_link=" + $(this).attr("selector_link") + "]").text($(this).val())});
                $(".selector-form select").change(function() { $("span[selector_link=" + $(this).attr("selector_link") + "]").text($(this).val())});
            }

            if (open_modal) {
                $("#modal_" + select_id).foundation("reveal", "open");
            }
        },

        selector_delete: function(selector_id) {
            $(".selectors[selector_id=" + selector_id + "]").remove();
            $("#modal_" + selector_id).remove();
            $(".selector-delete[selector_id=" + selector_id + "]").parent().parent().remove();

        },

        build_select: function (selector_id, value, columns, end, name, wrapper) {
            wrapper = typeof  wrapper !== 'undefined' ? wrapper : true;

            select_name = "selectors["+ selector_id +"][" + name + "]";
            selector_link = selector_id + "_" + name.replace("][", "_");
            class_name = "";

            options = [];

            switch (name) {
                case "is_active":
                    class_name = "selector_is_active";
                    options = [
                            {value: 1, text: "true", selected: value == "true"},
                            {value: 0, text: "false", selected: value == "false"}
                    ];
                    break;
                case "regexp][mode":
                    options = [
                            {value: "gsub", text: "gsub", selected: value == "gsub"},
                            {value: "match", text: "match", selected: value == "match"}
                    ];
                    break;
                case "to_type":
                    options = [
                            {value: "string", text: "string", selected: value == "string"},
                            {value: "symbol", text: "symbol", selected: value == "symbol"},
                            {value: "integer", text: "integer", selected: value == "integer"},
                            {value: "float", text: "float", selected: value == "float"}
                    ];
                    break;
                case "value_type":
                    class_name = "selector_value_type";
                    $.each( types, function( index, type ) {
                       options.push({value: type, text: type, selected: value == type});
                    });
                    break;
            }

            element = $("<select />", { name: select_name, selector_link: selector_link, selector_id: selector_id, class: class_name });

            $.each(options, function(index, option) {
                element.append(
                    $("<option />", { value: option["value"], text: option["text"], selected: option["selected"]})
                );
            });

            return wrapper == true ? methods.build_wrapper(element, columns, end, name) : element;
        },

        build_input: function (selector_id, value, columns, end, name, wrapper) {
            wrapper = typeof  wrapper !== 'undefined' ? wrapper : true;

            input_name = "selectors["+ selector_id +"][" + name + "]";
            selector_link = selector_id +"_" + name.replace("][", "_");
            element = $("<input />", {type: "text", name: input_name, value: value, selector_link: selector_link});
            return wrapper == true ? methods.build_wrapper(element, columns, end, name) : element;
        },

        build_wrapper: function(element, columns, end, name) {
            class_name = "medium-" + columns + " columns";
            if (end == true) { class_name += " end"; }

            wrapper = $("<div class='row'/>")
                .append($('<div class="medium-4 columns"><label>' + name +'</label></div>'))
                .append($('<div/>', {class: class_name}).append(element.addClass("medium-12")));

            return wrapper;
        },

        build_multi_wrapper: function (elements, name) {
            wrapper = $("<div class='row'/>")
                .append($('<div class="medium-4 columns"><label>' + name +'</label></div>'));

            $.each(elements, function (index, element) {
                wrapper.append(
                    $('<div class="medium-'+ element['columns'] +' columns" />')
                        .append($("<div class='row collapse' />").append(
                            $('<div class="medium-' + element['element']['label'] + ' columns"><span  class="prefix">' + index +'</span></div>'))
                            .append(
                                $('<div class="medium-' + element['element']['columns'] + ' columns"/>')
                                    .append(element['element']['html'].addClass("medium-12")
                                )
                            )
                        )
                );
            });

            return wrapper;
        },

        recalculate_priority: function () {
            i = 0;
            $(".selector_priority").each(function () {
                $(this).text(i);
                $("input[selector_link=" + $(this).attr("selector_id") + "_priority]").val(i);
                i++;
            });
        },

        init_selectors: function () {
            selector_table = $("<table id='sortable'/>");
            seletor_thead = $("<thead>").append(
                $("<tr />")
                    .append($("<th />", {text: "ID", width: "210px"}))
                    .append($("<th />", {text: "Value type", width:"150px"}))
                    .append($("<th />", {text: "Active", width: "65px"}))
                    .append($("<th />", {text: "Priority", width: "80px"}))
                    .append($("<th />", {text: ""}))
                    .append($("<th />", {text: "", width: "50px"}))
                    .append($("<th />", {text: "", width: "50px"}))
            );

            selector_tbody = $("<tbody />");

            $(".selectors").each(function(index){
                selector_id = $(this).attr("selector_id");
                url = '/api/selector/' + selector_id + "/";

                $.getJSON( url, function(data) {
                    methods.selector_append(selector_id, data);
                });
            });

            selector_table
                .append(seletor_thead)
                .append(selector_tbody)
            ;

            $this.append( $("<div />", {class: "row"}).append(selector_table) );

            methods.recalculate_priority();

            $( "#sortable tbody" ).sortable({ stop: function( event, ui ) { methods.recalculate_priority.apply(); } });
        },

        selector_append: function(selector_id, data, is_new) {
            is_new = typeof is_new == "undefined" ? false : is_new;
            selectors[selector_id] = data;
            active_class = data["is_active"] == true ? "fi-check medium color-green" : "fi-x medium color-red";


            regexp = "mode: " + data["regexp"]["mode"] + "; pattern: " + data["regexp"]["pattern"];

            info = $("<td />")
                .append($("<strong />", {text: "xpath: "})).append($("<span />", {text: data["xpath"], selector_link: data["_id"]["$oid"] + "_xpath"})).append($("<br />"))
                .append($("<strong />", {text: "css: "})).append($("<span />", {text: data["css"], selector_link: data["_id"]["$oid"] + "_css"})).append($("<br />"))
                .append($("<strong />", {text: "offset: "}))
                .append($("<span />", {text: "start: "}))
                .append($("<span />", {text: data["offset"]["start"], selector_link: data["_id"]["$oid"] + "_offset_start"}))
                .append($("<span />", {text: "; end: "}))
                .append($("<span />", {text: data["offset"]["end"], selector_link: data["_id"]["$oid"] + "_offset_end"}))
                .append($("<br />"))
                .append($("<strong />", {text: "regexp: "}))
                .append($("<span />", {text: "mode: "}))
                .append($("<span />", {text: data["regexp"]["mode"], selector_link: data["_id"]["$oid"] + "_regexp_mode"}))
                .append($("<span />", {text: "; end: "}))
                .append($("<span />", {text: data["regexp"]["pattern"], selector_link: data["_id"]["$oid"] + "_regexp_pattern"}))
                .append($("<br />"))
                .append($("<strong />", {text: "delimiter: "})).append($("<span />", {text: data["delimiter"], selector_link: data["_id"]["$oid"] + "_delimiter"}))
            ;

            ID = is_new ? "New!" : data["_id"]["$oid"];
            value_type_params = {
                class: "label",
                text: data["value_type"],
                style: "background-color: #" + type_color[data["value_type"]],
                id: "selector_value_type_" + selector_id
            };

            selector_tbody.append(
                $("<tr />")
                    .append($("<td />", {text: ID}))
                    .append($("<td />").append($("<span />", value_type_params)))
                    .append($("<td />").append($("<span />", { class: active_class, id: "selector_is_active_" + selector_id })))
                    .append($("<td />").append($("<span />", { class: "selector_priority", selector_id: selector_id, selector_link: selector_id + "_priority"  , text: data["priority"]})))
                    .append($("<td />").append(info))
                    .append($("<td />").append($("<a/>", {class: "fi-wrench medium selector-edit", selector_id: selector_id, href:"javascript:void(0);"})))
                    .append($("<td />").append($("<a/>", {class: "fi-skull medium selector-delete color-red", selector_id: selector_id, href:"javascript:void(0);"})))
            );

            methods.selector_edit(selector_id, is_new);
        },

        selector_add: function (value_type) {
            selector_id = "new_" +Math.round(+new Date()/1000);

            data = {
                "_id":{"$oid": selector_id},
                "attr":"",
                "css":"",
                "date_format":"",
                "delimiter":null,
                "is_active":true,
                "js_code":"",
                "link_template":"",
                "offset":{"start":0,"end":0},
                "priority":0,
                "regexp":{"mode":"gsub","pattern":""},
                "to_type":"",
                "value_type": value_type,
                "xpath":""
            };

            methods.selector_append(selector_id, data, true);
        },



        empty: function() {}
    };

    $.fn.selectors = function () { methods.init.apply( this ) };
} )( jQuery );

$( document ).ready( function () { $( "#selectors" ).selectors() } );
