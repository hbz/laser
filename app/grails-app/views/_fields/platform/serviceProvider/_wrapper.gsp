<div class="control-group">
  <label class="control-label" for="sector">${message(code:'platform.serviceProvider', default:'Service Provider')}</label>
  <div class="controls">
    <g:set value="${com.k_int.kbplus.RefdataCategory.getAllRefdataValues(de.laser.helper.RDConstants.Y_N_O)}" var="refvalues"/>
    <g:select from="${refvalues}" optionKey="id" optionValue="${{it.getI10n('value')}}" name="serviceProvider" />
  </div>
</div>
