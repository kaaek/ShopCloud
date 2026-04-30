package com.shopcloud.catalog.product;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public class StockChangeRequest {
    @NotNull
    @Min(1)
    private Integer quantity;

    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }
}
