using erp4sme.salesorder as so from '../db';

namespace erp4sme.salesorder;

service AdminService {
    @odata.draft.enabled
    entity Products   as projection on so.Products actions {
        @(
            cds.odata.bindingparameter.name : '_it',
            Core.OperationAvailable         : _it.IsActiveEntity,
            Common.SideEffects              : {TargetProperties : ['_it/stock']}
        )
        action increaseStock(
        @title              : '{i18n>Quantity}'
        @Validation.Maximum : 1
        quantity : Integer);
    };

    entity Categories as projection on so.Categories;
}
