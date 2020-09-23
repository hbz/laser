<%@ page import="de.laser.SurveyConfig; de.laser.RefdataCategory;de.laser.properties.PropertyDefinition;de.laser.RefdataValue; de.laser.helper.RDStore" %>
<laser:serviceInjection/>

<!doctype html>
<html>
<head>
    <meta name="layout" content="semanticUI"/>
    <title>${message(code: 'laser')} : ${message(code: 'survey.label')}</title>
</head>

<body>

<semui:breadcrumbs>
    <semui:crumb controller="survey" action="currentSurveysConsortia" text="${message(code: 'menu.my.surveys')}"/>
    <g:if test="${surveyInfo}">
        <semui:crumb controller="survey" action="show" id="${surveyInfo.id}" params="[surveyConfigID: surveyConfig.id]"
                     text="${surveyConfig.getConfigNameShort()}"/>
    </g:if>
    <semui:crumb message="surveyTransfer.label" class="active"/>
</semui:breadcrumbs>

<semui:controlButtons>
    <g:render template="actions"/>
</semui:controlButtons>

<h1 class="ui icon header"><semui:headerTitleIcon type="Survey"/>
<semui:xEditable owner="${surveyInfo}" field="name"/>
<semui:surveyStatusWithRings object="${surveyInfo}" surveyConfig="${surveyConfig}" controller="survey"
                             action="surveyEvaluation"/>
</h1>

<g:render template="nav"/>

<semui:objectStatus object="${surveyInfo}" status="${surveyInfo.status}"/>

<semui:messages data="${flash}"/>


<h2>
    ${message(code: 'surveyInfo.transfer')}
</h2>

<g:if test="${!(surveyInfo.status in [RDStore.SURVEY_IN_EVALUATION, RDStore.SURVEY_COMPLETED])}">
    <div class="ui segment">
        <b>${message(code: 'renewalWithSurvey.notInEvaliation')}</b>
    </div>
</g:if>
<g:else>

    <semui:form>

            <g:render template="evaluationParticipantsView" model="[showCheckbox: true, showTransferFields: true]"/>

    </semui:form>
</g:else>



</body>
</html>