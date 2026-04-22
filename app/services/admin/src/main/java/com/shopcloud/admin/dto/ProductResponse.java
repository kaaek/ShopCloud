package com.shopcloud.admin.dto;

import java.math.BigDecimal;
import java.time.Instant;

public record ProductResponse(
        Long id,
        String sku,
        String name,
        String description,
        BigDecimal price,
        Integer stock,
        Boolean active,
        Instant createdAt,
        Instant updatedAt
) {}
