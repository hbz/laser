package de.laser

import com.k_int.kbplus.RefdataValue
import com.k_int.kbplus.abstract_domain.AbstractProperty

class PropertyService {

    def grailsApplication
    def genericOIDService

    def evalFilterQuery(params, base_qry, hqlVar, base_qry_params) {

        if (params.filterPropDef) {
            def pd = genericOIDService.resolveOID(params.filterPropDef)
            
            if (pd.tenant) {
                base_qry += " and exists ( select gProp from ${hqlVar}.privateProperties as gProp where gProp.type = :propDef "
            } else {
                base_qry += " and exists ( select gProp from ${hqlVar}.customProperties as gProp where gProp.type = :propDef "
            }
            base_qry_params.put('propDef', pd)
            
            if (params.filterProp) {

                switch (pd.type) {
                    case RefdataValue.toString():
                        base_qry += " and gProp.refValue= :prop "
                        def pdValue = genericOIDService.resolveOID(params.filterProp)
                        base_qry_params.put('prop', pdValue)

                        break
                    case Integer.toString():
                        base_qry += " and gProp.intValue = :prop "
                        base_qry_params.put('prop', AbstractProperty.parseValue(params.filterProp, pd.type))
                        break
                    case String.toString():
                        base_qry += " and gProp.stringValue = :prop "
                        base_qry_params.put('prop', AbstractProperty.parseValue(params.filterProp, pd.type))
                        break
                    case BigDecimal.toString():
                        base_qry += " and gProp.decValue = :prop "
                        base_qry_params.put('prop', AbstractProperty.parseValue(params.filterProp, pd.type))
                        break
                    case Date.toString():
                        base_qry += " and gProp.dateValue = :prop "
                        base_qry_params.put('prop', AbstractProperty.parseValue(params.filterProp, pd.type))
                        break
                }
            }

            base_qry += " ) "
        }

        return [base_qry, base_qry_params]
    }
}

