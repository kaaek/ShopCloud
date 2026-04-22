package com.shopcloud.admin.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;

public record UpdateProductRequest(
        @Size(max = 200) String name,
        @Size(max = 1000) String description,
        @DecimalMin(value = "0.0", inclusive = false) BigDecimal price,
        @Min(0) Integer stock,
        Boolean active
) {}
