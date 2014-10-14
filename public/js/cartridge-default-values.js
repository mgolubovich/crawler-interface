( function( $ ) {
    var list;
    var used_fields = [];
    var default_area;
    var select;

    var methods = {
        init : function () {
            $.ajaxSetup( { async: false } );
            $.getJSON( '/api/default-tender-values', function( data ) { list = data } );

            methods.init_default_element.apply( this );
            methods.init_list_default_values.apply();

            add_button.click( function() { methods.add_value.apply() } );
            $(".remove_default_value").click( function() { methods.remove_value.apply( this ) } );
        },

        init_default_element: function () {
            default_area = this;
            manager_wrapper = $( "<div />", { class: "row collapse" } );

            params = {
                name: "add_default_value",
                type: "button",
                value: "Добавить значение",
                class: "button postfix"
            };

            add_button = $( '<input />', params );
            button_wrapper = $( "<div />", { class: "medium-3 columns end" }).append(add_button);

            select = $( '<select />' , { id: "default_values", class: "form-control" } );
            $.each( list, function( index, value ) {
                option = $( "<option />", { value: index, text: value } );

                if ( used_fields.indexOf( index ) >= 0 ) {
                    option.attr( 'disabled', true );
                }

                select.append( option );
            });

            select_wrapper = $( "<div />", { class: "medium-9 columns" }).append(select);



            manager_wrapper.append( select_wrapper );
            manager_wrapper.append( button_wrapper );
            default_area.append(manager_wrapper);
        },

        init_list_default_values: function () {

            $(".default_values").each( function() {
                input = $( this );
                human_field = list[input.attr('name')];
                methods.add_value(input.attr('name'), human_field, input.val());
            });
            $(".default_values").remove();
        },

        add_value : function (field, field_human, value) {

            if (typeof field == 'undefined') {
                field = select.val();
                field_human = select.find('option:selected').text();
                value = '';
            }

            if (field == '' || field == null) {
                return false;
            }

            params = {
                name: "cartridge[default_tender_values][" + field + "]",
                id: field,
                type: "text",
                value: value
            };

            input = $( "<input />", params );
            input_wrapper = $( "<div />", { class: "medium-8 columns" }).append(input);

            label = $("<div />", { class: "medium-2 columns" }).append($("<span />", { class: "prefix" }).text(field_human));

            params = {
                type: "button",
                class: "remove_default_value button btn-orange postfix",
                value: "Удалить значение"
            };

            remove_button = $( "<input />", params );
            remove_button_wrapper = $( "<div />", { class: "medium-2 columns end" }).append(remove_button);

            wrapper = $( "<div />", { class: "row collapse" } );
            wrapper.append(label);
            wrapper.append(input_wrapper);
            wrapper.append(remove_button_wrapper);

            default_area.append(wrapper);
            used_fields.push(field);

            option_find = "option[value='" + field + "']";
            select.find( option_find ).attr( { disabled:  true, selected: false }  );

            $(".remove_default_value").click( function() { methods.remove_value.apply( this ) } );
        },

        remove_value : function () {
            field = $( this ).parent().prev().children().attr( "id" );
            $( this ).parent().parent().remove();

            option_find = "option[value='" + field + "']";
            select.find(option_find).attr( 'disabled', false );
            select.find("option:enabled").first().prop( { selected: true } );

            position = used_fields.indexOf( field );
            used_fields.splice( position, 1 );
        }
    };

    $.fn.tenderField = function () { methods.init.apply( this ) };
} )( jQuery );

$( document ).ready( function () { $( "#default_values" ).tenderField() } );
