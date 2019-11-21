<%@ page import="de.laser.domain.MailTemplate" %>
<!doctype html>
<html>
<head>
    <meta name="layout" content="semanticUI"/>
    <title>${message(code: 'laser', default: 'LAS:eR')} ${message(code: 'mailTemplate.plural.label')}</title>
</head>

<body>

<semui:breadcrumbs>
    <semui:crumb message="mailTemplate.plural.label" class="active"/>
</semui:breadcrumbs>

<semui:controlButtons>
    <semui:actionsDropdown>
        <semui:actionsDropdownItem data-semui="modal" href="#modalCreateMailTemplate" message="mailTemplate.create.button"/>
    </semui:actionsDropdown>
</semui:controlButtons>

<h1 class="ui left aligned icon header"><semui:headerIcon/>${message(code: 'mailTemplate.plural.label')}</h1>

<semui:messages data="${flash}"/>
<semui:form>
    <g:if test="${mailTemplates?.size() > 0}">

        <table class="ui celled sortable table table-tworow la-table">
            <thead>
            <tr>
                <th>${message(code: 'sidewide.number')}</th>
                <th>${message(code: 'mailTemplate.name.label')}</th>
                <th>${message(code: 'mailTemplate.type.label')}</th>
                <th>${message(code: 'mailTemplate.language.label')}</th>
                <th>${message(code: 'mailTemplate.owner.label')}</th>
                <th class="la-action-info">${message(code: 'default.actions')}</th>
            </tr>
            </thead>
            <tbody>
            <g:each in="${mailTemplates}" var="template" status="i">
                <tr>
                    <td> ${i+1}</td>
                    <td>
                            ${template.name}
                    </td>

                    <td>
                            ${template.type.getI10n('value')}
                    </td>

                    <td>
                            ${template.language.getI10n('value')}
                    </td>

                    <td>
                            <g:if test="${template.owner}">
                                ${template.owner.name}
                            </g:if>
                    </td>

                    <td>
                        <button type="button" class="ui icon button la-popup-tooltip la-delay"
                                data-mailTemplateTarget="${de.laser.domain.MailTemplate.class.name}:${template.id}"
                                data-mailTemplateName="${template.name}"
                                data-mailTemplateSubject="${template.subject}"
                                data-mailTemplateText="${template.text}"
                                data-mailTemplateType="${template.type.id}"
                                data-mailTemplateLanguage="${template.language.id}"
                                data-semui="modal"
                                data-href="#editMailTemplate"
                                data-content="Mail Template ändern" data-position="top left"><i class="edit icon"></i></button>
                    </td>

                </tr>
            </g:each>
            </tbody>
        </table>

    </g:if>
    <g:else>
        <div class="container alert-warn">
            ${message(code: 'result.empty')}
        </div>
    </g:else>
</semui:form>


<semui:modal id="editMailTemplate" message="mailTemplate.label" isEditModal="isEditModal">

    <g:form class="ui form" url="[controller: 'dataManager', action: 'editMailTemplate']">
        <input type="hidden" name="target" value="" />
        <div class="field fieldcontain required">
            <label for="mailTemplateName">${message(code:'mailTemplate.name.label')}:</label>

            <input type="text" id="mailTemplateNameEdit" name="name" />
        </div>

        <div class="field fieldcontain required">
            <label for="mailTemplateSubject">${message(code:'mailTemplate.subject.label')}:</label>

            <input type="text" id="mailTemplateSubjectEdit" name="subject" />
        </div>

        <div class="field fieldcontain">
            <label for="mailTemplateText">${message(code:'mailTemplate.text.label')}:</label>

            <g:textArea  id="mailTemplateTextEdit" name="text" rows="5" cols="40"/>
        </div>

        <div  class="field fieldcontain required">
            <label for="mailTemplateLanguage">${message(code:'mailTemplate.language.label')}:</label>
            <g:select id="mailTemplateLanguageEdit"
                      name="language"
                      from="${com.k_int.kbplus.RefdataCategory.getAllRefdataValues('MailTemplate Language')}"
                      optionKey="id"
                      optionValue="${{it.getI10n('value')}}"
                      class="ui dropdown search many-to-one"
                      noSelection="[null: '']"/>
        </div>

        <div  class="field fieldcontain required">
            <label for="mailTemplateType">${message(code:'mailTemplate.type.label')}:</label>
            <g:select id="mailTemplateTypeEdit"
                      name="type"
                      from="${com.k_int.kbplus.RefdataCategory.getAllRefdataValues('MailTemplate Type')}"
                      optionKey="id"
                      optionValue="${{it.getI10n('value')}}"
                      class="ui dropdown search many-to-one"
                      noSelection="[null: '']"/>
        </div>
    </g:form>

    <r:script>
        dcbStore.modal.show.editMailTemplate = function(trigger) {
            $('#editMailTemplate #mailTemplateNameEdit').attr('value', $(trigger).attr('data-mailTemplateName'))
            $('#editMailTemplate #mailTemplateSubjectEdit').attr('value', $(trigger).attr('data-mailTemplateSubject'))
            $('#editMailTemplate #mailTemplateTextEdit').attr('value', $(trigger).attr('data-mailTemplateText'))
            $('#editMailTemplate input[name=target]').attr('value', $(trigger).attr('data-mailTemplateTarget'))
            $('#editMailTemplate select[name=type]').dropdown('set selected', $(trigger).attr('data-mailTemplateType'))
            $('#editMailTemplate select[name=language]').dropdown('set selected', $(trigger).attr('data-mailTemplateLanguage'))
        }
    </r:script>

</semui:modal>

<semui:modal id="modalCreateMailTemplate" text="${message(code:'mailTemplate.create.label')}">

    <g:form id="create_mail_template" class="ui form" url="[controller:'dataManager', action:'createMailTemplate']" method="post">

        <div class="field fieldcontain required">
            <label for="mailTemplateName">${message(code:'mailTemplate.name.label')}:</label>

            <input type="text" id="mailTemplateName" name="name" />
        </div>

        <div class="field fieldcontain required">
            <label for="mailTemplateSubject">${message(code:'mailTemplate.subject.label')}:</label>

            <input type="text" id="mailTemplateSubject" name="subject" />
        </div>

        <div class="field fieldcontain">
            <label for="mailTemplateText">${message(code:'mailTemplate.text.label')}:</label>

            <g:textArea  id="mailTemplateText" name="text" rows="5" cols="40"/>
        </div>

        <div  class="field fieldcontain required">
        <label for="mailTemplateLanguage">${message(code:'mailTemplate.language.label')}:</label>
        <g:select id="mailTemplateLanguage"
                  name="language"
                  from="${com.k_int.kbplus.RefdataCategory.getAllRefdataValues('MailTemplate Language')}"
                  optionKey="id"
                  optionValue="${{it.getI10n('value')}}"
                  class="ui dropdown search many-to-one"
                  noSelection="[null: '']"/>
        </div>

        <div  class="field fieldcontain required">
            <label for="mailTemplateType">${message(code:'mailTemplate.type.label')}:</label>
            <g:select id="mailTemplateType"
                      name="type"
                      from="${com.k_int.kbplus.RefdataCategory.getAllRefdataValues('MailTemplate Type')}"
                      optionKey="id"
                      optionValue="${{it.getI10n('value')}}"
                      class="ui dropdown search many-to-one"
                      noSelection="[null: '']"/>
        </div>

    </g:form>
</semui:modal>

</body>
</html>