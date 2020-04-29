<%@ page import="com.k_int.kbplus.*; com.k_int.kbplus.abstract_domain.AbstractProperty; com.k_int.kbplus.UserSettings;" %><laser:serviceInjection /><%@ page Content-type: text/plain; charset=utf-8; %><g:set var="userName" value="${raw(user.getDisplayName())}"/><g:set var="orgName" value="${raw(org.name)}"/><g:set var="language" value="${user.getSetting(UserSettings.KEYS.LANGUAGE_OF_EMAILS, RefdataValue.getByValueAndCategory('de',de.laser.helper.RDConstants.LANGUAGE)).value}"/><g:set var="grailsApplication" bean="grailsApplication" /><g:set var="surveyUrl" value="${survey.surveyConfigs[0].pickAndChoose ? "/survey/surveyTitlesSubscriber/${survey.id}?participant=${org.id}" : "/survey/evaluationParticipant/${survey.id}?surveyConfigID=${survey.surveyConfigs[0].id}&participant=${org.id}"}"/>
${message(code: 'email.text.title', locale: language)} ${userName},

${message(code: 'email.subject.surveysParticipationFinish', locale: language)}: ${orgName}

${survey.name} (<g:formatDate format="${message(code:'default.date.format.notime', default:'yyyy-MM-dd')}" date="${survey.startDate}"/> - <g:formatDate format="${message(code:'default.date.format.notime', default:'yyyy-MM-dd')}" date="${survey.endDate}"/>)

${message(code: 'email.survey.text2', locale: language)}
${grailsApplication.config.grails.serverURL+raw(surveyUrl)}


<g:render template="/mailTemplates/text/signature" />