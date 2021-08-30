using {
    cuid,
    managed,
    Currency
} from '@sap/cds/common';

annotate cuid with {
    ID @(
        title : '{i18n>ID}',
        UI.HiddenFilter,
        Core.Computed,
        UI.Hidden
    );
}

annotate managed with @(UI.FieldGroup #Admin : {
    Label : '{i18n>Products.Admin}',
    Data  : [
        {Value : createdBy},
        {Value : createdAt},
        {Value : modifiedBy},
        {Value : modifiedAt}
    ]
});

aspect hasCurrency {
    @Common : {
        Text            : currency.name,
        TextArrangement : #TextFirst,
        ValueListWithFixedValues
    }
    currency : Currency;
}