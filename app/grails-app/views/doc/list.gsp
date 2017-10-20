
<%@ page import="com.k_int.kbplus.Doc" %>
<!doctype html>
<html>
	<head>
		<meta name="layout" content="mmbootstrap">
		<g:set var="entityName" value="${message(code: 'doc.label', default: 'Doc')}" />
		<title><g:message code="default.list.label" args="[entityName]" /></title>
	</head>
	<body>
		<div class="container">
				
				<div class="page-header">
					<h1><g:message code="default.list.label" args="[entityName]" /></h1>
				</div>

				<g:if test="${flash.message}">
				<bootstrap:alert class="alert-info">${flash.message}</bootstrap:alert>
				</g:if>
				
				<table class="table table-striped table-bordered">
					<thead>
						<tr>
						
							<th class="header"><g:message code="doc.status.label" default="Status" /></th>
						
							<th class="header"><g:message code="doc.type.label" default="Type" /></th>
						
							<th class="header"><g:message code="doc.alert.label" default="Alert" /></th>
						
							<g:sortableColumn property="content" title="${message(code: 'doc.content.label', default: 'Content')}" />
						
							<g:sortableColumn property="uuid" title="${message(code: 'doc.uuid.label', default: 'Uuid')}" />
						
							<g:sortableColumn property="contentType" title="${message(code: 'doc.contentType.label', default: 'Content Type')}" />
						
							<th></th>
						</tr>
					</thead>
					<tbody>
					<g:each in="${docInstanceList}" var="docInstance">
						<tr>
						
							<td>${fieldValue(bean: docInstance, field: "status")}</td>
						
							<td>${fieldValue(bean: docInstance, field: "type")}</td>
						
							<td>${fieldValue(bean: docInstance, field: "alert")}</td>
						
							<td>${fieldValue(bean: docInstance, field: "content")}</td>
						
							<td>${fieldValue(bean: docInstance, field: "uuid")}</td>
						
							<td>${fieldValue(bean: docInstance, field: "contentType")}</td>
						
							<td class="link">
								<g:link action="show" id="${docInstance.id}" class="btn btn-small">Show &raquo;</g:link>
							</td>
						</tr>
					</g:each>
					</tbody>
				</table>
				<div class="pagination">
					<bootstrap:paginate total="${docInstanceTotal}" />
				</div>

		</div>
	</body>
</html>
