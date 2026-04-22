package com.shopcloud.cart.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CartDto {
    private String sessionId;
    private List<CartItemDto> items;
    private int totalQuantity;
    private BigDecimal totalPrice;
    private Instant createdAt;
    private Instant updatedAt;
}
