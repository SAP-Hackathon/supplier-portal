using erp4sme.salesorder as so from '../db';

annotate so.Products with {

    price          @(Measures.ISOCurrency : currency_code);
    thumbnailImage @UI.IsImageURL : true;

}
