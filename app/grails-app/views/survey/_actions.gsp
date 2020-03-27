<%@ page import="de.laser.helper.RDStore" %>
<semui:actionsDropdown>
    <g:if test="${springSecurityService.getCurrentUser().hasAffiliation("INST_ADM")}">
        <g:if test="${actionName == 'currentSurveysConsortia' || actionName == 'workflowsSurveysConsortia'}">

            <semui:actionsDropdownItem controller="survey" action="createGeneralSurvey"
                                       message="createGeneralSurvey.label"/>

            <semui:actionsDropdownItem controller="survey" action="createSubscriptionSurvey"
                                       message="createSubscriptionSurvey.label"/>

            <semui:actionsDropdownItem controller="survey" action="createIssueEntitlementsSurvey"
                                       message="createIssueEntitlementsSurvey.label"/>

            <g:if test="${actionName == 'currentSurveysConsortia'}">
                <div class="ui divider"></div>

                <semui:actionsDropdownItem controller="survey" action="workflowsSurveysConsortia"
                                           message="workflowsSurveysConsortia.label"/>
            </g:if>

        </g:if>
        <g:else>

            <g:if test="${surveyInfo && surveyInfo.checkOpenSurvey() && (surveyInfo.status?.id == de.laser.helper.RDStore.SURVEY_IN_PROCESSING?.id)}">
                <semui:actionsDropdownItem controller="survey" action="processOpenSurvey" params="[id: params.id]"
                                           message="openSurvey.button"
                                           tooltip="${message(code: "openSurvey.button.info2")}"/>
                <semui:actionsDropdownItem controller="survey" action="processOpenSurveyNow"
                                           params="[id: params.id]"
                                           message="openSurveyNow.button"
                                           tooltip="${message(code: "openSurveyNow.button.info2")}"/>
                <div class="ui divider"></div>
            </g:if>
            <g:if test="${surveyInfo && !surveyInfo.checkOpenSurvey() && (surveyInfo.status?.id == de.laser.helper.RDStore.SURVEY_IN_PROCESSING?.id)}">
                <semui:actionsDropdownItemDisabled controller="survey" action="processOpenSurvey"
                                                   params="[id: params.id]"
                                                   message="openSurvey.button"
                                                   tooltip="${message(code: "openSurvey.button.info")}"/>

                <semui:actionsDropdownItemDisabled controller="survey" action="processOpenSurveyNow"
                                                   params="[id: params.id]"
                                                   message="openSurveyNow.button"
                                                   tooltip="${message(code: "openSurveyNow.button.info")}"/>
                <div class="ui divider"></div>
            </g:if>

            <g:if test="${surveyInfo && surveyInfo.status?.id == de.laser.helper.RDStore.SURVEY_SURVEY_STARTED?.id}">
                <semui:actionsDropdownItem controller="survey" action="processEndSurvey" params="[id: params.id]"
                                           message="endSurvey.button"
                                           tooltip="${message(code: "endSurvey.button.info")}"/>
                <div class="ui divider"></div>
            </g:if>

            <g:if test="${surveyInfo.isSubscriptionSurvey && surveyConfig && surveyConfig?.type == 'Subscription' && !surveyConfig?.pickAndChoose
                    && surveyInfo.status?.id in [de.laser.helper.RDStore.SURVEY_IN_EVALUATION?.id, de.laser.helper.RDStore.SURVEY_COMPLETED?.id]}">
                <semui:actionsDropdownItem controller="survey" action="renewalWithSurvey"
                                           params="[surveyConfigID: surveyConfig?.id, id: surveyInfo?.id]"
                                           message="surveyInfo.renewal.action"/>
                <div class="ui divider"></div>
                <semui:actionsDropdownItem controller="survey" action="compareMembersOfTwoSubs"
                                           params="[surveyConfigID: surveyConfig?.id, id: surveyInfo?.id]"
                                           message="surveyInfo.transferOverView"/>
                <div class="ui divider"></div>

                <g:if test="${surveyInfo && surveyInfo.status?.id == de.laser.helper.RDStore.SURVEY_SURVEY_COMPLETED?.id}">
                    <semui:actionsDropdownItem controller="survey" action="setInEvaluation" params="[id: params.id]"
                                               message="evaluateSurvey.button" tooltip=""/>
                    <div class="ui divider"></div>
                </g:if>

                <g:if test="${surveyInfo && surveyInfo.status?.id == de.laser.helper.RDStore.SURVEY_IN_EVALUATION?.id}">
                    <semui:actionsDropdownItem controller="survey" action="setCompleteSurvey" params="[id: params.id]"
                                               message="completeSurvey.button" tooltip=""/>
                    <div class="ui divider"></div>

                </g:if>
            </g:if>

            <g:if test="${surveyInfo && surveyInfo.status?.id in [de.laser.helper.RDStore.SURVEY_IN_EVALUATION?.id, de.laser.helper.RDStore.SURVEY_SURVEY_COMPLETED?.id,de.laser.helper.RDStore.SURVEY_COMPLETED?.id]}">

                <semui:actionsDropdownItem data-semui="modal"
                                           href="#openSurveyAgain"
                                           message="openSurveyAgain.button"/>
                <div class="ui divider"></div>

            </g:if>

            <g:if test="${(!surveyInfo.isSubscriptionSurvey) && surveyInfo && surveyInfo.status?.id in [de.laser.helper.RDStore.SURVEY_IN_EVALUATION?.id, de.laser.helper.RDStore.SURVEY_SURVEY_COMPLETED?.id]}">
                <semui:actionsDropdownItem controller="survey" action="setCompleteSurvey" params="[id: params.id]"
                                           message="completeSurvey.button" tooltip=""/>
                <div class="ui divider"></div>

            </g:if>

            <g:if test="${!surveyConfig?.pickAndChoose && (surveyInfo.status?.id == de.laser.helper.RDStore.SURVEY_IN_PROCESSING?.id)}">
                <semui:actionsDropdownItem controller="survey" action="allSurveyProperties" params="[id: params.id]"
                                           message="survey.SurveyProp.all"/>

                <div class="ui divider"></div>
            </g:if>

            <g:if test="${surveyConfig?.orgs}">
                <semui:actionsDropdownItem data-semui="modal"
                                           href="#copyEmailaddresses_static"
                                           message="survey.copyEmailaddresses.participants"/>

                <g:set var="orgs"
                       value="${com.k_int.kbplus.Org.findAllByIdInList(surveyConfig?.orgs?.org?.flatten().unique { a, b -> a?.id <=> b?.id }.id)?.sort { it.sortname }}"/>

                <g:render template="copyEmailaddresses"
                          model="[modalID: 'copyEmailaddresses_static', orgList: orgs ?: null]"/>
            </g:if>
            <g:else>
                <semui:actionsDropdownItemDisabled message="survey.copyEmailaddresses.participants"
                                                   tooltip="${message(code: "survey.copyEmailaddresses.NoParticipants.info")}"/>
            </g:else>

            <g:if test="${surveyInfo.status.id in [RDStore.SURVEY_IN_PROCESSING.id, RDStore.SURVEY_READY.id] && editable}">
                <div class="ui divider"></div>

                <g:link class="item js-open-confirm-modal"
                        data-confirm-tokenMsg="${message(code: "confirm.dialog.delete.survey", args: [surveyConfig?.getSurveyName()])}"
                        data-confirm-term-how="delete"
                        controller="survey" action="deleteSurveyInfo"
                        id="${surveyInfo?.id}">
                    <i class="trash alternate icon"></i> ${message(code:'deletion.survey')}
                </g:link>

            </g:if>
        </g:else>
    </g:if>
</semui:actionsDropdown>

<g:if test="${surveyInfo && surveyInfo.status?.id in [de.laser.helper.RDStore.SURVEY_IN_EVALUATION?.id, de.laser.helper.RDStore.SURVEY_SURVEY_COMPLETED?.id,de.laser.helper.RDStore.SURVEY_COMPLETED?.id]}">
    <semui:modal id="openSurveyAgain" text="${message(code:'openSurveyAgain.button')}" msgSave="${message(code:'openSurveyAgain.button')}">

        <g:form class="ui form"
                url="[controller: 'survey', action: 'openSurveyAgain', params: [id: params.id, surveyConfigID: surveyConfig?.id], method: 'post']">
            <div class="field">
                <semui:datepicker label="surveyInfo.endDate.new" id="newEndDate" name="newEndDate" placeholder="surveyInfo.endDate.new" />
            </div>
        </g:form>

    </semui:modal>
</g:if>

<g:javascript>

$('.trigger-modal').on('click', function(e) {
    e.preventDefault();
    var orgIdList = $(this).attr('data-orgIdList');
    var targetId = $(this).attr('data-targetId');

    if (orgIdList && targetId) {
        $("html").css("cursor", "wait");

        $.ajax({
            url: "<g:createLink controller='survey' action='copyEmailaddresses'/>",
            data: {
                orgListIDs: orgIdList,
                targetId: targetId
            }
        }).done( function(data) {
            console.log(targetId)
            $('.ui.dimmer.modals > #' + targetId).remove();
            $('#dynamicModalContainer').empty().html(data);

            $('#dynamicModalContainer .ui.modal').modal({

                onVisible: function () {
                    console.log(targetId)
                    r2d2.initDynamicSemuiStuff('#' + targetId);
                    r2d2.initDynamicXEditableStuff('#' + targetId);
                }
                ,
                detachable: true,
                autofocus: false,
                closable: false,
                transition: 'scale',
                onApprove : function() {
                    $(this).find('.ui.form').submit();
                    return false;
                }
            }).modal('show');
        }).always( function() {
            $("html").css("cursor", "auto");
        });
    }
})

</g:javascript>