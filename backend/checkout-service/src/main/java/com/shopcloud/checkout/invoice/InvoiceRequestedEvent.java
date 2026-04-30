package com.shopcloud.checkout.invoice;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

public record InvoiceRequestedEvent(
        Long orderId,
        Long userId,
        String customerEmail,
        BigDecimal totalAmount,
        String currency,
        Instant createdAt,
        List<InvoiceItemEvent> items
) {
}