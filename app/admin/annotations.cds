using erp4sme.salesorder.AdminService as service from '../../srv/admin-service';

////////////////////////////////////////////////////////////////////////////
//
//	Categories List
//
annotate service.Categories with @(UI : {
    //Columns in Value help table, only the first column is used
    Identification : [{Value : name}],
    LineItem       : [
        {Value : identifier},
        {Value : name},
        {Value : description}
    ]
});


////////////////////////////////////////////////////////////////////////////
//
//	Products List
//
annotate service.Products with @(UI : {
    SelectionFields : [category_ID],
    LineItem        : [
        {
            Value             : thumbnailImage,
            ![@UI.Importance] : #Low
        },
        {Value : identifier},
        {Value : name},
        {Value : category_ID},
        {Value : price},
        {Value : stock}
    ]
});

annotate service.Products {
    description   @UI.MultiLineText;
    currency_code @UI.Hidden  @UI.HiddenFilter;
    category
                  @Common.ValueList : {
        CollectionPath : 'Categories',
        Parameters     : [
            {
                $Type             : 'Common.ValueListParameterInOut',
                ValueListProperty : 'ID',
                LocalDataProperty : category_ID
            },
            {
                $Type             : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'identifier'
            },
            {
                $Type             : 'Common.ValueListParameterDisplayOnly',
                ValueListProperty : 'name'
            }
        ]
    }
}


annotate service.Categories {
    ID
    @Common : {
        Text            : name,
        TextArrangement : #TextOnly
    };
}

////////////////////////////////////////////////////////////////////////////
//
//	Products Details
//
annotate service.Products with
@(UI : {
    Identification                 : [{
        $Type  : 'UI.DataFieldForAction',
        Label  : '{i18n>IncreaseStock}',
        Action : 'erp4sme.salesorder.AdminService.increaseStock',
    // ![@UI.Hidden] : IsActiveEntity
    }],
    HeaderInfo                     : {
        TypeName       : '{i18n>Product}',
        TypeNamePlural : '{i18n>Products}',
        ImageUrl       : image,
        Title          : {Value : name},
        Description    : {Value : identifier}
    },
    HeaderFacets                   : [
        {
            $Type             : 'UI.ReferenceFacet',
            Target            : '@UI.DataPoint#price',
            ![@UI.Importance] : #High
        },
        {
            $Type             : 'UI.ReferenceFacet',
            Target            : '@UI.DataPoint#stock',
            ![@UI.Importance] : #High
        }
    ],
    Facets                         : [{
        $Type  : 'UI.CollectionFacet',
        Label  : '{i18n>Products.GeneralInformation}',
        ID     : 'GeneralInformation',
        Facets : [
            {
                $Type  : 'UI.ReferenceFacet',
                Label  : '{i18n>Products.Basic}',
                Target : '@UI.FieldGroup#GeneralInformation'
            },
            {
                $Type  : 'UI.ReferenceFacet',
                Label  : '{i18n>Products.Admin}',
                Target : '@UI.FieldGroup#Admin'
            },
        ]
    }],
    FieldGroup #GeneralInformation : {
        $Type : 'UI.FieldGroupType',
        Label : '{i18n>GeneralInformation}',
        Data  : [
            {Value : identifier},
            {Value : name},
            {Value : image},
            {Value : description},
            {Value : price}
        ]
    },
    DataPoint #price               : {
        Value : price,
        Title : '{i18n>Products.Price}'
    },
    DataPoint #stock               : {
        $Type : 'UI.DataPointType',
        Value : stock,
        Title : '{i18n>Products.Stock}'
    },
});
