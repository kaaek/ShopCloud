package com.shopcloud.cart.entity;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.redis.core.RedisHash;
import org.springframework.data.redis.core.TimeToLive;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@RedisHash("carts")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Cart {
    @Id
    private String sessionId;

    @Builder.Default
    private List<CartItem> items = new ArrayList<>();

    private Instant createdAt;
    private Instant updatedAt;

    @TimeToLive
    private Long ttlSeconds;
}
