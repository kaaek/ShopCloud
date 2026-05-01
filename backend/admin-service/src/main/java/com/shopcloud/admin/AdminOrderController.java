package com.shopcloud.admin;

import com.shopcloud.admin.client.CheckoutAdminClient;
import com.shopcloud.admin.dto.OrderDto;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/orders")
@PreAuthorize("hasRole('ADMIN')")
public class AdminOrderController {

    private final CheckoutAdminClient checkoutAdminClient;

    public AdminOrderController(CheckoutAdminClient checkoutAdminClient) {
        this.checkoutAdminClient = checkoutAdminClient;
    }

    @GetMapping
    public List<OrderDto> allOrders() {
        return checkoutAdminClient.allOrders();
    }

    @PostMapping("/{id}/return")
    public OrderDto markReturned(@PathVariable Long id) {
        return checkoutAdminClient.markReturned(id);
    }
}
