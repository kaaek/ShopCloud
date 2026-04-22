package com.shopcloud.catalog.service;

import com.shopcloud.catalog.dto.ProductDto;
import com.shopcloud.catalog.entity.Product;
import com.shopcloud.catalog.repo.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProductService {
    private final ProductRepository productRepository; // For communicating with the database.

    @Transactional(readOnly = true)
    public List<ProductDto> getAllProducts() {
        return productRepository.findAll()
                .stream()
                .map(this::toDto)
                .toList();
    }

    @Transactional(readOnly = true)
    public ProductDto getProductById(Long id) {
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found"));
        return toDto(product);
    }

    @Transactional
    public ProductDto createProduct(ProductDto dto) {
        if (productRepository.findByProductName(dto.getProductName()).isPresent()) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Product name already exists");
        }

        Product saved = productRepository.save(toEntity(dto));
        return toDto(saved);
    }

    @Transactional
    public ProductDto updateProduct(Long id, ProductDto dto) {
        Product existing = productRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found"));

        productRepository.findByProductName(dto.getProductName()) // Looks up any product with the incoming name using findByProductName.
                // If one is found, it checks whether that found product is not the same record being updated
                .filter(product -> !product.getId().equals(id))
                .ifPresent(product -> {
                    // If it is a different record, it throws HTTP 409 Conflict with Product name already exists.
                    // It blocks renaming a product to a name already used by another product.
                    throw new ResponseStatusException(HttpStatus.CONFLICT, "Product name already exists");
                });
        // If no product is found, or it is the same product, update continues.
        existing.setProductName(dto.getProductName());
        existing.setProductDescription(dto.getProductDescription());
        existing.setProductStatus(dto.getProductStatus());
        existing.setProductCategory(dto.getProductCategory());
        existing.setProductRating(dto.getProductRating());
        existing.setProductPrice(dto.getProductPrice());
        existing.setProductQuantity(dto.getProductQuantity());
        existing.setProductImageUrl(dto.getProductImageUrl());

        Product updated = productRepository.save(existing);
        return toDto(updated);
    }

    @Transactional
    public void deleteProduct(Long id) {
        if (!productRepository.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Product not found");
        }
        productRepository.deleteById(id);
    }

    private ProductDto toDto(Product product) {
        return ProductDto.builder()
                .id(product.getId())
                .productName(product.getProductName())
                .productDescription(product.getProductDescription())
                .productStatus(product.getProductStatus())
                .productCategory(product.getProductCategory())
                .productRating(product.getProductRating())
                .productPrice(product.getProductPrice())
                .productQuantity(product.getProductQuantity())
                .productImageUrl(product.getProductImageUrl())
                .build();
    }

    private Product toEntity(ProductDto dto) {
        return Product.builder()
                .id(dto.getId())
                .productName(dto.getProductName())
                .productDescription(dto.getProductDescription())
                .productStatus(dto.getProductStatus())
                .productCategory(dto.getProductCategory())
                .productRating(dto.getProductRating())
                .productPrice(dto.getProductPrice())
                .productQuantity(dto.getProductQuantity())
                .productImageUrl(dto.getProductImageUrl())
                .build();
    }
}
