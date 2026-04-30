package com.shopcloud.checkout.order;

import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/internal/orders")
public class InternalOrderController {

    private final CheckoutService checkoutService;

    public InternalOrderController(CheckoutService checkoutService) {
        this.checkoutService = checkoutService;
    }

    @GetMapping
    public List<CustomerOrder> allOrders() {
        return checkoutService.allOrders();
    }

    @PostMapping("/{id}/return")
    public CustomerOrder markReturned(@PathVariable Long id) {
        return checkoutService.markReturned(id);
    }
}
