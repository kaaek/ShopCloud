package com.shopcloud.cart.service;

import com.shopcloud.cart.dto.AddCartItemRequest;
import com.shopcloud.cart.dto.CartDto;
import com.shopcloud.cart.dto.CartItemDto;
import com.shopcloud.cart.dto.UpdateCartItemRequest;
import com.shopcloud.cart.entity.Cart;
import com.shopcloud.cart.entity.CartItem;
import com.shopcloud.cart.repo.CartRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CartService {
    private final CartRepository cartRepository;

    @Value("${cart.ttl-days:30}")
    private long cartTtlDays;

    public CartDto getCart(String sessionId) {
        Cart cart = findOrCreateCart(sessionId);
        cart.setUpdatedAt(Instant.now());
        return toDto(saveCart(cart));
    }

    public CartDto addItem(String sessionId, AddCartItemRequest request) {
        Cart cart = findOrCreateCart(sessionId);

        CartItem existingItem = findItem(cart, request.getProductId());
        if (existingItem == null) {
            cart.getItems().add(toCartItem(request));
        } else {
            existingItem.setProductName(request.getProductName());
            existingItem.setUnitPrice(request.getUnitPrice());
            existingItem.setProductImageUrl(request.getProductImageUrl());
            existingItem.setQuantity(existingItem.getQuantity() + request.getQuantity());
        }

        cart.setUpdatedAt(Instant.now());
        return toDto(saveCart(cart));
    }

    public CartDto updateItemQuantity(String sessionId, Long productId, UpdateCartItemRequest request) {
        Cart cart = findOrCreateCart(sessionId);
        CartItem item = findItem(cart, productId);

        if (item == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Cart item not found");
        }

        item.setQuantity(request.getQuantity());
        cart.setUpdatedAt(Instant.now());
        return toDto(saveCart(cart));
    }

    public CartDto removeItem(String sessionId, Long productId) {
        Cart cart = findOrCreateCart(sessionId);
        boolean removed = cart.getItems().removeIf(item -> item.getProductId().equals(productId));

        if (!removed) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Cart item not found");
        }

        cart.setUpdatedAt(Instant.now());
        return toDto(saveCart(cart));
    }

    public CartDto clearCart(String sessionId) {
        Cart cart = findOrCreateCart(sessionId);
        cart.setItems(new ArrayList<>());
        cart.setUpdatedAt(Instant.now());
        return toDto(saveCart(cart));
    }

    public void deleteCart(String sessionId) {
        cartRepository.deleteById(sessionId);
    }

    private Cart findOrCreateCart(String sessionId) {
        Cart cart = cartRepository.findById(sessionId)
                .orElseGet(() -> Cart.builder()
                        .sessionId(sessionId)
                        .items(new ArrayList<>())
                        .createdAt(Instant.now())
                        .updatedAt(Instant.now())
                        .ttlSeconds(ttlSeconds())
                        .build());

        if (cart.getItems() == null) {
            cart.setItems(new ArrayList<>());
        }

        return cart;
    }

    private Cart saveCart(Cart cart) {
        cart.setTtlSeconds(ttlSeconds());
        return cartRepository.save(cart);
    }

    private CartItem findItem(Cart cart, Long productId) {
        return cart.getItems()
                .stream()
                .filter(item -> item.getProductId().equals(productId))
                .findFirst()
                .orElse(null);
    }

    private CartItem toCartItem(AddCartItemRequest request) {
        return CartItem.builder()
                .productId(request.getProductId())
                .productName(request.getProductName())
                .unitPrice(request.getUnitPrice())
                .quantity(request.getQuantity())
                .productImageUrl(request.getProductImageUrl())
                .build();
    }

    private CartDto toDto(Cart cart) {
        List<CartItemDto> itemDtos = cart.getItems()
                .stream()
                .map(this::toItemDto)
                .toList();

        int totalQuantity = itemDtos.stream()
                .mapToInt(CartItemDto::getQuantity)
                .sum();

        BigDecimal totalPrice = itemDtos.stream()
                .map(CartItemDto::getLineTotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return CartDto.builder()
                .sessionId(cart.getSessionId())
                .items(itemDtos)
                .totalQuantity(totalQuantity)
                .totalPrice(totalPrice)
                .createdAt(cart.getCreatedAt())
                .updatedAt(cart.getUpdatedAt())
                .build();
    }

    private CartItemDto toItemDto(CartItem item) {
        BigDecimal lineTotal = item.getUnitPrice()
                .multiply(BigDecimal.valueOf(item.getQuantity()));

        return CartItemDto.builder()
                .productId(item.getProductId())
                .productName(item.getProductName())
                .unitPrice(item.getUnitPrice())
                .quantity(item.getQuantity())
                .productImageUrl(item.getProductImageUrl())
                .lineTotal(lineTotal)
                .build();
    }

    private long ttlSeconds() {
        return Duration.ofDays(cartTtlDays).toSeconds();
    }
}
