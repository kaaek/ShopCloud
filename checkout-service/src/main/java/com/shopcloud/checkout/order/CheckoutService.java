package com.shopcloud.checkout.order;

import com.shopcloud.checkout.client.CartClient;
import com.shopcloud.checkout.client.CartItemDto;
import com.shopcloud.checkout.client.CatalogClient;
import com.shopcloud.checkout.client.ProductDto;
import com.shopcloud.checkout.invoice.InvoicePublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

@Service
public class CheckoutService {

    private final CartClient cartClient;
    private final CatalogClient catalogClient;
    private final OrderRepository orderRepository;
    private final InvoicePublisher invoicePublisher;

    public CheckoutService(CartClient cartClient,
                           CatalogClient catalogClient,
                           OrderRepository orderRepository,
                           InvoicePublisher invoicePublisher) {
        this.cartClient = cartClient;
        this.catalogClient = catalogClient;
        this.orderRepository = orderRepository;
        this.invoicePublisher = invoicePublisher;
    }

    @Transactional
    public CustomerOrder checkout(Long userId, String customerEmail) {
        List<CartItemDto> cartItems = cartClient.getCart(userId);
        if (cartItems == null || cartItems.isEmpty()) {
            throw new IllegalStateException("Cart is empty");
        }

        CustomerOrder order = new CustomerOrder();
        order.setUserId(userId);
        order.setStatus(OrderStatus.CONFIRMED);
        order.setCreatedAt(Instant.now());

        BigDecimal total = BigDecimal.ZERO;

        for (CartItemDto item : cartItems) {
            ProductDto product = catalogClient.getProduct(item.getProductId());
            if (product == null) {
                throw new IllegalArgumentException("Product not found: " + item.getProductId());
            }
            if (product.getStock() < item.getQuantity()) {
                throw new IllegalStateException("Not enough stock for product: " + product.getName());
            }

            BigDecimal lineTotal = product.getPrice().multiply(BigDecimal.valueOf(item.getQuantity()));
            total = total.add(lineTotal);

            order.addItem(new OrderLine(
                    product.getId(),
                    product.getName(),
                    item.getQuantity(),
                    product.getPrice()
            ));
        }

        // Simulated payment success. Real payment gateway is intentionally not included.
        boolean paymentConfirmed = true;
        if (!paymentConfirmed) {
            throw new IllegalStateException("Payment failed");
        }

        for (CartItemDto item : cartItems) {
            catalogClient.decreaseStock(item.getProductId(), item.getQuantity());
        }

        order.setTotalAmount(total);
        CustomerOrder saved = orderRepository.save(order);
        cartClient.clearCart(userId);
        invoicePublisher.publishInvoiceRequested(saved, customerEmail);
        return saved;
    }

    public List<CustomerOrder> myOrders(Long userId) {
        return orderRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    public CustomerOrder getMyOrder(Long userId, Long orderId) {
        CustomerOrder order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found"));
        if (!order.getUserId().equals(userId)) {
            throw new IllegalArgumentException("Order does not belong to this user");
        }
        return order;
    }

    public List<CustomerOrder> allOrders() {
        return orderRepository.findAll();
    }

    @Transactional
    public CustomerOrder markReturned(Long orderId) {
        CustomerOrder order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found"));
        order.setStatus(OrderStatus.RETURNED);
        return order;
    }
}
