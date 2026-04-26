package com.shopcloud.catalog.product;

import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/products")
public class PublicProductController {

    private final ProductService productService;

    public PublicProductController(ProductService productService) {
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

    @GetMapping("/search")
    public List<Product> search(@RequestParam(required = false) String keyword,
                                @RequestParam(required = false) String category) {
        if (keyword != null && !keyword.isBlank()) {
            return productService.search(keyword);
        }
        if (category != null && !category.isBlank()) {
            return productService.byCategory(category);
        }
        return productService.getAllProducts();
    }
}
