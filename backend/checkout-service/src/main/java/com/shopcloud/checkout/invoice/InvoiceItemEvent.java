package com.shopcloud.checkout.invoice;

import java.math.BigDecimal;

public record InvoiceItemEvent(
        Long productId,
        String productName,
        Integer quantity,
        BigDecimal unitPrice,
        BigDecimal lineTotal
) {
}