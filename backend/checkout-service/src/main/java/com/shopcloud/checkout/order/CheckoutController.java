package com.shopcloud.checkout.order;

import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
public class CheckoutController {

    private final CheckoutService checkoutService;

    public CheckoutController(CheckoutService checkoutService) {
        this.checkoutService = checkoutService;
    }

    @PostMapping("/api/checkout")
    public CustomerOrder checkout(Authentication authentication) {
        Long userId = (Long) authentication.getDetails();
        String email = authentication.getName();
        return checkoutService.checkout(userId, email);
    }

    @GetMapping("/api/orders/my")
    public List<CustomerOrder> myOrders(Authentication authentication) {
        Long userId = (Long) authentication.getDetails();
        return checkoutService.myOrders(userId);
    }

    @GetMapping("/api/orders/{id}")
    public CustomerOrder myOrder(Authentication authentication, @PathVariable Long id) {
        Long userId = (Long) authentication.getDetails();
        return checkoutService.getMyOrder(userId, id);
    }
}
