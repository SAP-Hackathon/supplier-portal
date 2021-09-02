const cds = require("@sap/cds");

module.exports = cds.service.impl(async (srv) => {
  const orderSrv = await cds.connect.to("erp4sme.salesorder.SalesOrderService");
  const { Products } = srv.entities;
  orderSrv.on("cap/msg/order/released", async (msg) => {
    console.debug("> received:", msg.event, msg.data);
    const { product, quantity } = msg.data;
    const { req } = msg.headers;
    const tx = cds.transaction(req);
    const result = await tx.run(UPDATE(Products)
        .where({ ID: product })
        .and("stock >=", quantity)
        .set("stock -=", quantity)
    );
    if (result == 0) {
        req.error({
            code: 400,
            message: `Quantity of Product ${product} not enough`,
        });
    }
  });

  srv.before("SAVE", srv.entities.Products, async function (req) {
    const product = req.data;
    product.thumbnailImage = product.image;
  });

  srv.on("increaseStock", srv.entities.Products, async function (req) {
    const quantity = req.data.quantity;
    const id = req.params[0]["ID"];
    const tx = cds.transaction(req);
    tx.run(
      UPDATE(srv.entities.Products)
        .set("stock = stock + " + quantity)
        .where({
          ID: id,
        })
    ).then(
      req.notify({
        code: "UPDATED",
        message: "Stock updated",
      })
    );
  });
});
