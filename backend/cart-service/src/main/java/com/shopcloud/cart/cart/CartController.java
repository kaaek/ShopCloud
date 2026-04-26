package com.shopcloud.cart.cart;

import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/cart")
public class CartController {

    private final CartService cartService;

    public CartController(CartService cartService) {
        this.cartService = cartService;
    }

    @GetMapping
    public List<CartItem> getCart(Authentication authentication) {
        return cartService.getCart(currentUserId(authentication));
    }

    @PostMapping("/items")
    public CartItem addItem(Authentication authentication,
                            @Valid @RequestBody CartItemRequest request) {
        return cartService.addItem(currentUserId(authentication), request);
    }

    @PutMapping("/items/{productId}")
    public CartItem updateItem(Authentication authentication,
                               @PathVariable Long productId,
                               @Valid @RequestBody CartItemRequest request) {
        return cartService.updateItem(currentUserId(authentication), productId, request);
    }

    @DeleteMapping("/items/{productId}")
    public void removeItem(Authentication authentication, @PathVariable Long productId) {
        cartService.removeItem(currentUserId(authentication), productId);
    }

    @DeleteMapping("/clear")
    public void clear(Authentication authentication) {
        cartService.clearCart(currentUserId(authentication));
    }

    private Long currentUserId(Authentication authentication) {
        return (Long) authentication.getDetails();
    }
}
