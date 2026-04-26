package com.shopcloud.cart.cart;

import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/internal/carts")
public class InternalCartController {

    private final CartService cartService;

    public InternalCartController(CartService cartService) {
        this.cartService = cartService;
    }

    @GetMapping("/users/{userId}")
    public List<CartItem> getCartForUser(@PathVariable Long userId) {
        return cartService.getCart(userId);
    }

    @DeleteMapping("/users/{userId}")
    public void clearCartForUser(@PathVariable Long userId) {
        cartService.clearCart(userId);
    }
}
