package com.shopcloud.catalog.product;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class ProductService {

    private final ProductRepository productRepository;

    public ProductService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    public Product getProduct(Long id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Product not found"));
    }

    public List<Product> search(String keyword) {
        return productRepository.findByNameContainingIgnoreCaseOrDescriptionContainingIgnoreCase(keyword, keyword);
    }

    public List<Product> byCategory(String category) {
        return productRepository.findByCategoryIgnoreCase(category);
    }

    public Product create(ProductRequest request) {
        Product product = new Product();
        copy(request, product);
        return productRepository.save(product);
    }

    public Product update(Long id, ProductRequest request) {
        Product product = getProduct(id);
        copy(request, product);
        return productRepository.save(product);
    }

    public void delete(Long id) {
        Product product = getProduct(id);
        productRepository.delete(product);
    }

    @Transactional
    public Product decreaseStock(Long id, int quantity) {
        Product product = getProduct(id);
        if (product.getStock() < quantity) {
            throw new IllegalStateException("Not enough stock for product " + id);
        }
        product.setStock(product.getStock() - quantity);
        return product;
    }

    @Transactional
    public Product increaseStock(Long id, int quantity) {
        Product product = getProduct(id);
        product.setStock(product.getStock() + quantity);
        return product;
    }

    private void copy(ProductRequest request, Product product) {
        product.setName(request.getName());
        product.setDescription(request.getDescription());
        product.setCategory(request.getCategory());
        product.setImageUrl(request.getImageUrl());
        product.setPrice(request.getPrice());
        product.setStock(request.getStock());
    }
}
