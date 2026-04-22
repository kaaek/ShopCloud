package com.shopcloud.cart.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AddCartItemRequest {
    @NotNull
    private Long productId;

    @NotBlank
    private String productName;

    @NotNull
    @DecimalMin("0.0")
    private BigDecimal unitPrice;

    @Min(1)
    private int quantity;

    @Pattern(
            regexp = "^(https?://).+",
            message = "productImageUrl must start with http:// or https://"
    )
    private String productImageUrl;
}
