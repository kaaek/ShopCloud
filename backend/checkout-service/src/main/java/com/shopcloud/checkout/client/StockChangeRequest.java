package com.shopcloud.checkout.client;

public class StockChangeRequest {
    private Integer quantity;

    public StockChangeRequest() {
    }

    public StockChangeRequest(Integer quantity) {
        this.quantity = quantity;
    }

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
}
