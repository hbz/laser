<%@ page import="com.k_int.kbplus.Cluster" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="semanticUI">
		<g:set var="entityName" value="${message(code: 'cluster.label')}" />
		<title><g:message code="default.create.label" args="[entityName]" /></title>
	</head>
	<body>
		<div>
		<div>
			
			<div class="span3">
				<div class="well">
					<ul class="nav nav-list">
						<li class="nav-header">${entityName}</li>
						<li>
							<g:link class="list" action="list">
								<i class="icon-list"></i>
								<g:message code="default.list.label" args="[entityName]" />
							</g:link>
						</li>
						<li class="active">
							<g:link class="create" action="create">
								<i class="icon-plus icon-white"></i>
								<g:message code="default.create.label" args="[entityName]" />
							</g:link>
						</li>
					</ul>
				</div>
			</div>
			
			<div class="span9">

				<h1 class="ui header la-clear-before"><semui:headerIcon /><g:message code="default.create.label" args="[entityName]" /></h1>

				<semui:messages data="${flash}" />

				<semui:errors bean="${clusterInstance}" />

				<fieldset>
					<g:form class="ui form" action="create" >
						<fieldset>
							<% // <f:all bean="clusterInstance"/> %>
							<g:render template="form"/>
							
							<div class="ui form-actions">
								<button type="submit" class="ui button">
									<i class="checkmark icon"></i>
									<g:message code="default.button.create.label" />
								</button>
							</div>
						</fieldset>
					</g:form>
				</fieldset>
				
			</div>

		</div>
		</div>
	</body>
</html>
