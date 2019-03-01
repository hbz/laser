<%@ page import="com.k_int.kbplus.RefdataCategory" %>
<!-- genericFilter.gsp -->

<div class="field">
    <label>${message(code: 'subscription.property.search')}
        <i class="question circle icon la-popup"></i>
        <div class="ui  popup ">
            <i class="shield alternate icon"></i> = ${message(code: 'subscription.properties.my')}
        </div>
    </label>
    <r:script>
        $(".la-popup").popup({
        });
    </r:script>
    <%-- value="${params.filterPropDef}" --%>
    <semui:dropdown id="filterPropDef" name="filterPropDef"

                    class="la-filterPropDef"
                    from="${propList.toSorted()}"
                    iconWhich = "shield alternate"
                    optionKey="${{
                        it.refdataCategory ?
                                "com.k_int.properties.PropertyDefinition:${it.id}\" data-rdc=\"com.k_int.kbplus.RefdataCategory:${RefdataCategory.findByDesc(it.refdataCategory)?.id}"
                                : "com.k_int.properties.PropertyDefinition:${it.id}"
                    }}"
                    optionValue="${{ it.getI10n('name') }}"
                    noSelection="${message(code: 'default.select.choose.label', default: 'Please Choose...')}"/>
</div>


<div class="field">
    <label for="filterProp">${message(code: 'subscription.property.value')}</label>

    <input id="filterProp" name="filterProp" type="text"
           placeholder="${message(code: 'license.search.property.ph')}" value="${params.filterProp ?: ''}"/>
</div>



<script type="text/javascript">


    $(function () {

        var propertyFilterController = {

            updateProp: function (selOpt) {


                //If we are working with RefdataValue, grab the values and create select box
                if (selOpt.attr('data-rdc')) {
                    $.ajax({
                        url: '<g:createLink controller="ajax" action="refdataSearchByOID"/>' + '?oid=' + selOpt.attr('data-rdc') + '&format=json',
                        success: function (data) {
                            var select = '<option value></option>';
                            for (var index = 0; index < data.length; index++) {
                                var option = data[index];
                                select += '<option value="' + option.value + '">' + option.text + '</option>';
                            }
                            select = '<select id="filterProp" name="filterProp" class="ui search selection dropdown">' + select + '</select>';

                            $('label[for=filterProp]').next().replaceWith(select);

                            $('#filterProp').dropdown({
                                duration: 150,
                                transition: 'fade'
                            });

                        }, async: false
                    });
                } else {
                    $('label[for=filterProp]').next().replaceWith(
                        '<input id="filterProp" type="text" name="filterProp" placeholder="${message(code:'license.search.property.ph', default:'property value')}" />'
                    )
                }
            },

            init: function () {

                /*
                // register change event
                $('#filterPropDef').change(function (e) {
                    var selOpt = $('option:selected', this);
                    propertyFilterController.updateProp(selOpt);
                });
             */
                $(document).ready(function() {
                    $(".la-filterPropDef").dropdown({
                        clearable: true,
                        onChange: function (value, text, $selectedItem) {
                            if ((typeof $selectedItem != 'undefined')){
                                var selOpt = $selectedItem;
                                propertyFilterController.updateProp(selOpt);
                            }
                            else {
                                $('#filterProp').dropdown ('clear', true)
                            }

                        }
                    });
                })
                    // set filterPropDef by params
                    // iterates through all the items and set the item class on 'active selected' when value and URL Parameter for filterPropDef match
                    var item = $( ".la-filterPropDef .item" );

                    var selOpt = $('.la-filterPropDef').find(item).filter(function ()
                        {
                        return  $(this).attr('data-value') == "${params.filterPropDef}";
                        }
                    ).addClass('active').addClass('selected');
                    // sets the URL Parameter on the hidden input field
                    var hiddenInput = $('#filterPropDef').val("${params.filterPropDef}");


                    propertyFilterController.updateProp(selOpt);

                    // set filterProp by params
                    var paramFilterProp = "${params.filterProp}";
                    if ($('#filterProp').is('input')) {
                        $('#filterProp').val(paramFilterProp);
                    }
                    else {
                        $('#filterProp option').filter(function () {
                            return $(this).val() == paramFilterProp;
                        }).prop('selected', true);
                    }

            }
        }


        propertyFilterController.init()
    });

</script>


<!-- genericFilter.gsp -->