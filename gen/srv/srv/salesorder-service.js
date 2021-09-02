const cds = require('@sap/cds')

module.exports = cds.service.impl(async (srv) => {

    srv.on("release", "SalesOrders", releaseOrder);
    srv.on("cancel", "SalesOrders", cancelProduct);
    srv.before("PATCH", "SalesOrderItems", updateFromProduct);
    srv.before("PATCH", "SalesOrderItems", updateNetAmount);
    srv.before("CREATE", "SalesOrders", beforeSalesOrderCreated);
    srv.before('UPDATE', 'SalesOrders', beforeSalesOrderUpdate);

    const { SalesOrders, SalesOrderItems, Products } = srv.entities
    const SalesOrderItemsDrafts = 'erp4sme_salesorder_SalesOrderService_SalesOrderItems_drafts';
    const SalesOrderDrafts = 'erp4sme_salesorder_SalesOrderService_SalesOrders_drafts';

    function getValue(input, field){
        return input[field]? input[field]: input[field.toUpperCase()];
    }

    function calculateItemNetAmount(item) {
        const netAmount = getValue(item, 'price') * ( getValue(item, 'quantity') ? getValue(item, 'quantity') : 0);
        return netAmount.toFixed(2);
    }

    function sumNetAmmount(salesOrderItems) {
        var netAmount = 0;
        salesOrderItems.forEach(item => {
            netAmount = netAmount + Number.parseFloat(getValue(item, 'netAmount'));
        });
        return netAmount;
    }

    async function beforeSalesOrderUpdate (req) {
        const salesOrder = req.data;
        salesOrder.netAmount = sumNetAmmount(salesOrder.salesOrderItems);
    }

    async function beforeSalesOrderCreated(req) {
        const newSalesOrder = req.data;
        newSalesOrder.netAmount = sumNetAmmount(newSalesOrder.salesOrderItems)
        newSalesOrder.lifecycleStatus_code = 0;
        return newSalesOrder;
    }

    async function releaseOrder(req) {
        const tx = cds.transaction(req);
        const salesOrder = await tx.run(SELECT.one.from(SalesOrders).where({ ID: req.query.SELECT.from.ref[0].where[2].val }));
        if (salesOrder.lifecycleStatus_code != 0) {
            req.error({
                code: 400,
                message: 'cannot release this order'
            })
        } else {
            const salesOrderItems = await tx.run(SELECT.from(SalesOrderItems).where({ salesOrder_ID: req.query.SELECT.from.ref[0].where[2].val }));
            await Promise.all(salesOrderItems.map(it => {
                srv.emit('cap/msg/order/released',{ product: it.product_ID, quantity: it.quantity }, {req});
            }))
            await tx.run(UPDATE(SalesOrders).where('ID =', req.query.SELECT.from.ref[0].where[2].val)
                .set('lifecycleStatus_code =', 1));
            req.notify({
                "code": "SALESORDER_RELEASED",
                "message": "Sales Order is released"
            });
        }
    }

    async function cancelProduct(req) {
        const tx = cds.transaction(req);
        const salesOrder = await tx.run(SELECT.one.from(SalesOrders).where({ ID: req.query.SELECT.from.ref[0].where[2].val }));
        if (salesOrder.lifecycleStatus_code != 1) {
            req.error({
                code: 400,
                message: 'cannot cancel this order'
            })
        } else {
            const salesOrderItems = await tx.run(SELECT.from(SalesOrderItems).where({ salesOrder_ID: req.query.SELECT.from.ref[0].where[2].val }));
            await Promise.all(salesOrderItems.map(it => 
                srv.emit('cap/msg/order/released',{ product: it.product_ID, quantity: -it.quantity }, {req})
            ))
            await tx.run(UPDATE(SalesOrders).where('ID =', req.query.SELECT.from.ref[0].where[2].val)
                .set('lifecycleStatus_code =', -1));
            req.notify({
                "code": "SALESORDER_CANCELLED",
                "message": "Sales Order is cancelled"
            });
        }
    }

    async function updateNetAmount(req) {
        const { product_ID, ID, price, quantity } = req.data;
        if (price || quantity) {
            console.log(`price or quantity updated: price -> ${price} quantity -> ${quantity}`)
            // calculate netAmount since any changes on price or quantity 
            // add calculation logic and update draft entity later
            // set draft table name of SalesOrders and SalesOrderItems
            const tx = cds.transaction(req);
            const salesOrderItem = await tx.run(SELECT.one.from(SalesOrderItemsDrafts).where({ ID: ID }));
            // show draft instance of SalesOrderItem
            console.log(salesOrderItem);
            if (price) { salesOrderItem.price = price }
            if (quantity) { salesOrderItem.quantity = quantity }
            await UPDATE(SalesOrderItemsDrafts).where('ID =', ID)
                .set({ netAmount: calculateItemNetAmount(salesOrderItem) })
            const salesOrderItems = await tx.run(SELECT.from(SalesOrderItemsDrafts).where({ salesOrder_ID: getValue(salesOrderItem, 'salesOrder_ID') }));
            await UPDATE(SalesOrderDrafts).where('ID =', getValue(salesOrderItem, 'salesOrder_ID'))
                .set('netAmount =', sumNetAmmount(salesOrderItems))
        }
    }

    async function updateFromProduct(req) {
        const { Products } = srv.entities
        const SalesOrderItemsDrafts = 'erp4sme_salesorder_SalesOrderService_SalesOrderItems_drafts';
        const SalesOrderDrafts = 'erp4sme_salesorder_SalesOrderService_SalesOrders_drafts';
        const tx = cds.transaction(req);
        const { product_ID, ID } = req.data;
        if (product_ID) {
            // read draft SalesOrderItem
            const salesOrderItem = await tx.run(SELECT.one.from(SalesOrderItemsDrafts).where({ ID: ID }));
            // read chosen Product information
            const product = await tx.run(SELECT.one.from(Products).where({ ID: product_ID }));
            // if chosen Product is not the same as before, update price and currency
            if (salesOrderItem.product_ID != product_ID) {
                salesOrderItem.price = product.price;
                salesOrderItem.currency_code = product.currency_code;
                // Update price and currency of SalesOrderItems draft table 
                await tx.run(UPDATE(SalesOrderItemsDrafts).where('ID =', ID)
                    .set({ price: getValue(salesOrderItem, 'price'), currency_code: getValue(salesOrderItem, 'currency_code'), netAmount: calculateItemNetAmount(salesOrderItem) }));
                // Read SalesOrderItems
                const salesOrderItems = await tx.run(SELECT.from(SalesOrderItemsDrafts).where({ salesOrder_ID: getValue(salesOrderItem, 'salesOrder_ID') }));
                // Update price and currency of SalesOrderItems draft table 
                await tx.run(UPDATE(SalesOrderDrafts).where('ID =', getValue(salesOrderItem, 'salesOrder_ID'))
                    .set('netAmount =', sumNetAmmount(salesOrderItems)));
            }
        }
    }

});