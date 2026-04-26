package com.shopcloud.cart.cart;

import com.shopcloud.cart.client.CatalogClient;
import com.shopcloud.cart.client.ProductDto;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class CartService {

    private final CartItemRepository cartItemRepository;
    private final CatalogClient catalogClient;

    public CartService(CartItemRepository cartItemRepository, CatalogClient catalogClient) {
        this.cartItemRepository = cartItemRepository;
        this.catalogClient = catalogClient;
    }

    public List<CartItem> getCart(Long userId) {
        return cartItemRepository.findByUserId(userId);
    }

    public CartItem addItem(Long userId, CartItemRequest request) {
        ProductDto product = catalogClient.getProduct(request.getProductId());
        if (product == null) {
            throw new IllegalArgumentException("Product not found");
        }

        CartItem item = cartItemRepository
                .findByUserIdAndProductId(userId, request.getProductId())
                .orElse(new CartItem(userId, request.getProductId(), 0));

        int newQuantity = item.getQuantity() + request.getQuantity();
        if (product.getStock() < newQuantity) {
            throw new IllegalStateException("Requested quantity is higher than stock");
        }

        item.setQuantity(newQuantity);
        return cartItemRepository.save(item);
    }

    public CartItem updateItem(Long userId, Long productId, CartItemRequest request) {
        ProductDto product = catalogClient.getProduct(productId);
        if (product == null) {
            throw new IllegalArgumentException("Product not found");
        }
        if (product.getStock() < request.getQuantity()) {
            throw new IllegalStateException("Requested quantity is higher than stock");
        }

        CartItem item = cartItemRepository.findByUserIdAndProductId(userId, productId)
                .orElseThrow(() -> new IllegalArgumentException("Cart item not found"));
        item.setQuantity(request.getQuantity());
        return cartItemRepository.save(item);
    }

    @Transactional
    public void removeItem(Long userId, Long productId) {
        cartItemRepository.deleteByUserIdAndProductId(userId, productId);
    }

    @Transactional
    public void clearCart(Long userId) {
        cartItemRepository.deleteByUserId(userId);
    }
}
