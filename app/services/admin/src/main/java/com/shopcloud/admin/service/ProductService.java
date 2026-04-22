package com.shopcloud.admin.service;

import com.shopcloud.admin.dto.CreateProductRequest;
import com.shopcloud.admin.dto.ProductResponse;
import com.shopcloud.admin.dto.UpdateProductRequest;
import com.shopcloud.admin.entity.Product;
import com.shopcloud.admin.exception.BadRequestException;
import com.shopcloud.admin.exception.ConflictException;
import com.shopcloud.admin.exception.NotFoundException;
import com.shopcloud.admin.repository.ProductRepository;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class ProductService {

    private final ProductRepository productRepository;

    public ProductService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    public ProductResponse create(CreateProductRequest request) {
        if (productRepository.existsBySku(request.sku())) {
            throw new ConflictException("Product with SKU already exists: " + request.sku());
        }

        Product product = new Product();
        product.setSku(request.sku());
        product.setName(request.name());
        product.setDescription(request.description());
        product.setPrice(request.price());
        product.setStock(request.stock());
        product.setActive(request.active() == null ? Boolean.TRUE : request.active());

        return toResponse(productRepository.save(product));
    }

    @Transactional(readOnly = true)
    public List<ProductResponse> getAll() {
        return productRepository.findAll().stream().map(this::toResponse).toList();
    }

    @Transactional(readOnly = true)
    public ProductResponse getById(Long id) {
        return toResponse(getProduct(id));
    }

    public ProductResponse update(Long id, UpdateProductRequest request) {
        Product product = getProduct(id);

        if (request.name() != null) product.setName(request.name());
        if (request.description() != null) product.setDescription(request.description());
        if (request.price() != null) product.setPrice(request.price());
        if (request.stock() != null) product.setStock(request.stock());
        if (request.active() != null) product.setActive(request.active());

        return toResponse(productRepository.save(product));
    }

    public ProductResponse addStock(Long id, Integer amount) {
        Product product = getProduct(id);
        product.setStock(product.getStock() + amount);
        return toResponse(productRepository.save(product));
    }

    public ProductResponse reduceStock(Long id, Integer amount) {
        Product product = getProduct(id);
        int newStock = product.getStock() - amount;
        if (newStock < 0) {
            throw new BadRequestException("Stock cannot go below zero");
        }
        product.setStock(newStock);
        return toResponse(productRepository.save(product));
    }

    public ProductResponse processReturn(Long id, Integer returnedQuantity) {
        return addStock(id, returnedQuantity);
    }

    public void delete(Long id) {
        Product product = getProduct(id);
        productRepository.delete(product);
    }

    private Product getProduct(Long id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Product not found: " + id));
    }

    private ProductResponse toResponse(Product product) {
        return new ProductResponse(
                product.getId(),
                product.getSku(),
                product.getName(),
                product.getDescription(),
                product.getPrice(),
                product.getStock(),
                product.getActive(),
                product.getCreatedAt(),
                product.getUpdatedAt()
        );
    }
}
