namespace erp4sme.salesorder;

using {
    managed,
    cuid,
    Currency,
    sap.common
} from '@sap/cds/common';
using {hasCurrency} from './common';
using {erp4sme.salesorder.Products} from './product';

type SalesOrderId : String(10)@(
    title          : 'Sales Order No.',
    Core.Immutable : true
);

type StatusCode : Integer enum {
    Open     = 0;
    Released = 1;
    Canceled = -1;
}

entity LifeCycleStatus {
    key code : StatusCode @Common : {
            Text            : text,
            TextArrangement : #TextOnly,
        };
        @title : '{i18n>Status}'
        text : localized String
}

entity SalesOrderType                         @(title : 'Sales Order Types') {
        @title : '{i18n>Order Type}'
    key salesOrderType             : String(4)@(Common : {
            Text            : salesOrderTypeText,
            TextArrangement : #TextFirst
        });
        salesOrderTypeText         : String(20);
        salesOrderProcessingType   : String(1);
        orderTypeForBillingRequest : String(4);
}

annotate BusinessPartners with {
    ID @Common : {
        Text            : identifier,
        TextArrangement : #TextOnly,
    };
}

entity BusinessPartners : cuid, managed {
    @title : '{i18n>Company Code}'
    @Common : {
        Text            : companyName,
        TextArrangement : #TextFirst,
    }
    identifier        : String(10);
    @title : '{i18n>Company Name}'
    companyName       : String(80);
    emailAddress      : String(255);
    phoneNumber       : String(30);
    mobilePhoneNumber : String(30);
    faxNumber         : String(30);
}

entity SalesOrderItems : cuid, managed, hasCurrency {
    @title : '{i18n>Item ID}'
    identifier   : String(10);
    @title : '{i18n>Gross Amount}'
    grossAmount  : Decimal(16, 2);
    @title : '{i18n>Net Amount}'
    @(Measures.ISOCurrency : currency_code)
    netAmount    : Decimal(16, 2);
    @title : '{i18n>Tax Amount}'
    taxAmount    : Decimal(16, 2);
    deliveryDate : Date;
    @title : '{i18n>Price}'
    @(Measures.ISOCurrency : currency_code)
    price        : Decimal(16, 2) default 0.0;
    @title : '{i18n>Quantity}'
    quantity     : Integer default 0;
    @title : '{i18n>Quantity Unit}'
    quantityUnit : String(3) default 'PC';
    @title : '{i18n>Product}'
    product      : Association to Products;
    salesOrder   : Association to one SalesOrders;
}

entity SalesOrders : cuid, managed, hasCurrency {
    @title  : '{i18n>Sales Order}'
    identifier       : SalesOrderId;
    @Core.Immutable
    @title  : '{i18n>Order Type}'
    orderType        : Association to SalesOrderType;
    buyerId          : String;
    buyerName        : String(80);
    grossAmount      : Decimal(15, 2);
    @title  : '{i18n>Net Amount}'
    @(Measures.ISOCurrency : currency_code)
    @readonly
    netAmount        : Decimal(15, 2);
    taxAmount        : Decimal(15, 2);
    @title  : '{i18n>Status}'
    @Common : {
        Text            : lifecycleStatus.text,
        TextArrangement : #TextOnly
    }
    lifecycleStatus  : Association to LifeCycleStatus;
    @title  : '{i18n>Sold-To Party}'
    soldToParty      : Association to BusinessPartners;
    businessPartners : Association to BusinessPartners;
    salesOrderItems  : Composition of many SalesOrderItems
                           on salesOrderItems.salesOrder = $self;
};
