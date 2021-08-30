using erp4sme.salesorder.SalesOrderService as service from '../../srv/salesorder-service';
using from '../ui-common';

// List View
annotate service.SalesOrders with
@(UI : {
    SelectionFields : [
        orderType_salesOrderType,
        soldToParty_ID,
        lifecycleStatus_code
    ],
    HeaderInfo      : {
        TypeName       : 'Sales Order',
        TypeNamePlural : 'Sales Order List',
        Title          : {
            Label : 'Order number',
            Value : identifier
        }
    },
    LineItem        : [
        {
            $Type             : 'UI.DataField',
            Value             : identifier,
            ![@UI.Importance] : #High,
        },
        {
            $Type             : 'UI.DataField',
            Value             : soldToParty.identifier,
            Label             : '{i18n>Sold-To Party}',
            ![@UI.Importance] : #High,
        },
        {
            $Type             : 'UI.DataField',
            Value             : orderType.salesOrderType,
            ![@UI.Importance] : #High,
        },
        {
            $Type             : 'UI.DataField',
            Value             : netAmount,
            ![@UI.Importance] : #High,
        },
        {
            $Type             : 'UI.DataField',
            Value             : lifecycleStatus_code,
            ![@UI.Importance] : #High,
        }
    ]
}) {
    lifecycleStatus @(
        title  : '{i18n>Status}',
        Common : {
            Text                     : lifecycleStatus.text,
            TextArrangement          : #TextOnly,
            FieldControl             : #ReadOnly,
            ValueList                : {
                Label          : 'Status Value Help',
                CollectionPath : 'LifeCycleStatus',
                Parameters     : [
                    {
                        $Type             : 'Common.ValueListParameterInOut',
                        LocalDataProperty : lifecycleStatus_code,
                        ValueListProperty : 'code'
                    },
                    {
                        $Type             : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty : 'text',
                    }
                ]
            },
            ValueListWithFixedValues : true
        }
    );
    soldToParty     @(
        title  : '{i18n>Sold-To Party}',
        Common : {
            Text                     : soldToParty.identifier,
            TextArrangement          : #TextOnly,
            FieldControl             : #Mandatory,
            ValueList                : {
                Label          : 'Sold-To Party Value Help',
                CollectionPath : 'BusinessPartners',
                Parameters     : [
                    {
                        $Type             : 'Common.ValueListParameterInOut',
                        LocalDataProperty : soldToParty_ID,
                        ValueListProperty : 'ID'
                    },
                    {
                        $Type             : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty : 'companyName',
                    },
                    {
                        $Type             : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty : 'identifier',
                    }
                ]
            },
            ValueListWithFixedValues : false
        }
    );
    orderType       @(
        title  : 'Order Type',
        Common : {
            Text                     : orderType.salesOrderTypeText,
            TextArrangement          : #TextFirst,
            FieldControl             : #Mandatory,
            ValueList                : {
                Label          : 'Sales Order Type Value Help',
                CollectionPath : 'SalesOrderType',
                Parameters     : [
                    {
                        $Type             : 'Common.ValueListParameterInOut',
                        LocalDataProperty : orderType_salesOrderType,
                        ValueListProperty : 'salesOrderType'
                    },
                    {
                        $Type             : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty : 'salesOrderTypeText'
                    }
                ]
            },
            ValueListWithFixedValues : true
        }
    );
};

@(Common : {
    SideEffects #productUpdate   : {
        SourceProperties : [product_ID],
        TargetEntities   : [
            product,
            salesOrder
        ],
        TargetProperties : [
            'price',
            'currency_code',
            'netAmount'
        ]
    },
    SideEffects #netAmountUpdate : {
        SourceProperties : [
            price,
            quantity
        ],
        TargetProperties : ['netAmount'],
        TargetEntities   : [salesOrder]
    }
})
annotate service.SalesOrderItems with
@(UI : {
    HeaderInfo : {
        TypeName       : 'Sales Order Item',
        TypeNamePlural : 'Sales Order Item List'
    },
    LineItem   : [
        {
            $Type             : 'UI.DataField',
            Value             : product.thumbnailImage,
            IconUrl           : product.thumbnailImage,
            ![@UI.Importance] : #High,
        },
        {
            $Type             : 'UI.DataField',
            Value             : product_ID,
            ![@UI.Importance] : #High,
        },
        {
            $Type             : 'UI.DataField',
            Value             : price,
            ![@UI.Importance] : #High,
        },
        {
            $Type             : 'UI.DataField',
            Value             : quantity,
            ![@UI.Importance] : #High,
        },
        {
            $Type             : 'UI.DataField',
            Value             : quantityUnit,
            ![@UI.Importance] : #High,
        },
        {
            $Type             : 'UI.DataField',
            Value             : netAmount,
            ![@UI.Importance] : #High,
        }
    ]
}) {
    product @(
        title  : 'Product',
        Common : {
            Text                     : product.identifier,
            TextArrangement          : #TextOnly,
            FieldControl             : #Mandatory,
            ValueList                : {
                Label          : 'Product Value Help',
                CollectionPath : 'Products',
                Parameters     : [
                    {
                        $Type             : 'Common.ValueListParameterInOut',
                        LocalDataProperty : product_ID,
                        ValueListProperty : 'ID'
                    },
                    {
                        $Type             : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty : 'thumbnailImage'
                    },
                    {
                        $Type             : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty : 'identifier'
                    },
                    {
                        $Type             : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty : 'name'
                    },
                    {
                        $Type             : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty : 'price'
                    }
                ]
            },
            ValueListWithFixedValues : false,
            SemanticObjectMapping : [
                {
                    $Type : 'Common.SemanticObjectMappingType',
                    LocalProperty : 'product_ID',
                    SemanticObjectProperty : 'ID',
                }
            ],
            SemanticObject : 'product'
        }
    );
};

// Object View
annotate service.SalesOrders with @(UI : {
    Identification                       : [
        {
            $Type  : 'UI.DataFieldForAction',
            Label  : 'Release',
            Action : 'erp4sme.salesorder.SalesOrderService.release'
        },
        {
            $Type  : 'UI.DataFieldForAction',
            Label  : 'Cancel',
            Action : 'erp4sme.salesorder.SalesOrderService.cancel'
        }
    ],
    HeaderFacets                         : [{
        $Type             : 'UI.ReferenceFacet',
        Target            : '@UI.FieldGroup#HeaderGeneralInformation',
        ![@UI.Importance] : #High
    }],
    Facets                               : [
        {
            $Type  : 'UI.CollectionFacet',
            Label  : 'Header',
            ID     : 'HeaderInfo',
            Facets : [{

                $Type  : 'UI.CollectionFacet',
                ID     : 'GeneralInfo',
                Label  : 'General Information',
                Facets : [{
                    $Type             : 'UI.ReferenceFacet',
                    Label             : 'Order Data',
                    ID                : 'OrderData',
                    Target            : '@UI.FieldGroup#OrderData',
                    ![@UI.Importance] : #High,
                    ![@UI.Hidden]     : false
                }]
            }]
        },
        {
            $Type  : 'UI.ReferenceFacet',
            Label  : 'Items',
            ID     : 'SalesOrderItems',
            Target : 'salesOrderItems/@UI.LineItem'
        }
    ],
    FieldGroup #HeaderGeneralInformation : {Data : [
        {
            $Type             : 'UI.DataField',
            Value             : identifier,
            ![@UI.Importance] : #High,
        },
        {
            $Type             : 'UI.DataField',
            Value             : orderType_salesOrderType,
            ![@UI.Importance] : #High,
        },
        {
            $Type             : 'UI.DataField',
            Value             : lifecycleStatus_code,
            ![@UI.Importance] : #High
        }
    ]},
    FieldGroup #OrderData                : {Data : [
        {
            $Type             : 'UI.DataField',
            Value             : soldToParty_ID,
            ![@UI.Importance] : #High,
        },
        {
            $Type             : 'UI.DataField',
            Value             : netAmount,
            Label             : 'Net Amount',
            ![@UI.Importance] : #High,
        }
    ]},
});
