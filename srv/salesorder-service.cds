using erp4sme.salesorder as so from '../db/sales-order';
using erp4sme.salesorder as prd from '../db/product';
using {sap.common} from '@sap/cds/common';

namespace erp4sme.salesorder;

service SalesOrderService {

    @readonly entity SalesOrderType   as projection on so.SalesOrderType;

    @readonly entity LifeCycleStatus   as projection on so.LifeCycleStatus;

    @readonly entity Products         as projection on prd.Products

    @readonly entity BusinessPartners as projection on so.BusinessPartners

    @odata.draft.enabled
    entity SalesOrders      as projection on so.SalesOrders actions{
        @(
            Common.SideEffects              : {
                TargetEntities   : [_it.lifecycleStatus]
            },
            cds.odata.bindingparameter.name : '_it'
        )
        action release();

        @(
            Common.SideEffects              : {
                TargetEntities   : [_it.lifecycleStatus]
            },
            cds.odata.bindingparameter.name : '_it'
        )
        action cancel();

        action test();
    }

};
