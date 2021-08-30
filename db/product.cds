using {
    managed,
    cuid,
    Currency,
    sap.common
} from '@sap/cds/common';
using {hasCurrency} from './common';

namespace erp4sme.salesorder;

annotate Products with {
    ID @(
        Common: {
            Text: identifier,
            TextArrangement : #TextFirst,
        }
    );
}

entity Products : cuid, managed {
    @title : '{i18n>Name}'
    name           : localized String;
    @title : '{i18n>Identifier}'
    identifier     : String;
    @(
        title  : '{i18n>Category}',
        Common : {
            Text            : name,
            TextArrangement : #TextOnly,
        }
    )
    category       : Association to Categories;
    @title : '{i18n>Description}'
    description    : localized String;
    @title : '{i18n>Currency}'  @Common : {
        Text            : currency.name,
        TextArrangement : #TextFirst,
        ValueListWithFixedValues
    }
    currency       : Currency;
    @title : '{i18n>Image}'
    image          : String;
    @title : '{i18n>ThumbnailImage}'
    thumbnailImage : String(100);
    isPreferred    : Boolean;
    @title : '{i18n>Rating}'
    rating         : Decimal(2, 1);
    @title : '{i18n>RelatedProduct}'
    relatedProduct : Association to Products;
    @title : '{i18n>Price}'
    @(Measures.ISOCurrency : currency_code)
    price          : Decimal(9, 2);
    @title : '{i18n>Stock}'
    stock          : Integer default 0;
}

entity Categories : cuid {
    @title : '{i18n>Name}'
    name           : localized String;
    @title : '{i18n>Identifier}'
    identifier     : String;
    parent         : Association to Categories;
    @title : '{i18n>Description}'
    description    : localized String;
    image          : String;
    thumbnailImage : String;
}
