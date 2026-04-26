package com.shopcloud.catalog.product;

import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/internal/products")
public class InternalProductController {

    private final ProductService productService;

    public InternalProductController(ProductService productService) {
        this.productService = productService;
    }

    @GetMapping
    public List<Product> all() {
        return productService.getAllProducts();
    }

    @GetMapping("/{id}")
    public Product byId(@PathVariable Long id) {
        return productService.getProduct(id);
    }

    @PostMapping
    public Product create(@Valid @RequestBody ProductRequest request) {
        return productService.create(request);
    }

    @PutMapping("/{id}")
    public Product update(@PathVariable Long id, @Valid @RequestBody ProductRequest request) {
        return productService.update(id, request);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        productService.delete(id);
    }

    @PostMapping("/{id}/decrease-stock")
    public Product decreaseStock(@PathVariable Long id, @Valid @RequestBody StockChangeRequest request) {
        return productService.decreaseStock(id, request.getQuantity());
    }

    @PostMapping("/{id}/increase-stock")
    public Product increaseStock(@PathVariable Long id, @Valid @RequestBody StockChangeRequest request) {
        return productService.increaseStock(id, request.getQuantity());
    }
}
