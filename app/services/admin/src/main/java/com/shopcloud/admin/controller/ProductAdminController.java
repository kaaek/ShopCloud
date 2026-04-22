package com.shopcloud.admin.controller;

import com.shopcloud.admin.dto.CreateProductRequest;
import com.shopcloud.admin.dto.ProductResponse;
import com.shopcloud.admin.dto.StockAdjustmentRequest;
import com.shopcloud.admin.dto.UpdateProductRequest;
import com.shopcloud.admin.service.ProductService;
import jakarta.validation.Valid;
import java.net.URI;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/products")
public class ProductAdminController {

    private final ProductService productService;

    public ProductAdminController(ProductService productService) {
        this.productService = productService;
    }

    @PostMapping
    public ResponseEntity<ProductResponse> create(@Valid @RequestBody CreateProductRequest request) {
        ProductResponse response = productService.create(request);
        return ResponseEntity.created(URI.create("/api/admin/products/" + response.id())).body(response);
    }

    @GetMapping
    public List<ProductResponse> getAll() {
        return productService.getAll();
    }

    @GetMapping("/{id}")
    public ProductResponse getById(@PathVariable Long id) {
        return productService.getById(id);
    }

    @PutMapping("/{id}")
    public ProductResponse update(@PathVariable Long id, @Valid @RequestBody UpdateProductRequest request) {
        return productService.update(id, request);
    }

    @PostMapping("/{id}/stock/increase")
    public ProductResponse increaseStock(@PathVariable Long id,
                                         @Valid @RequestBody StockAdjustmentRequest request) {
        return productService.addStock(id, request.amount());
    }

    @PostMapping("/{id}/stock/decrease")
    public ProductResponse decreaseStock(@PathVariable Long id,
                                         @Valid @RequestBody StockAdjustmentRequest request) {
        return productService.reduceStock(id, request.amount());
    }

    @PostMapping("/{id}/returns")
    public ProductResponse processReturn(@PathVariable Long id,
                                         @Valid @RequestBody StockAdjustmentRequest request) {
        return productService.processReturn(id, request.amount());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        productService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
