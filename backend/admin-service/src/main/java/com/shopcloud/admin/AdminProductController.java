package com.shopcloud.admin;

import com.shopcloud.admin.client.CatalogAdminClient;
import com.shopcloud.admin.dto.ProductDto;
import com.shopcloud.admin.dto.ProductRequest;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/products")
@PreAuthorize("hasRole('ADMIN')")
public class AdminProductController {

    private final CatalogAdminClient catalogAdminClient;

    public AdminProductController(CatalogAdminClient catalogAdminClient) {
        this.catalogAdminClient = catalogAdminClient;
    }

    @GetMapping
    public List<ProductDto> allProducts() {
        return catalogAdminClient.allProducts();
    }

    @PostMapping
    public ProductDto createProduct(@Valid @RequestBody ProductRequest request) {
        return catalogAdminClient.createProduct(request);
    }

    @PutMapping("/{id}")
    public ProductDto updateProduct(@PathVariable Long id, @Valid @RequestBody ProductRequest request) {
        return catalogAdminClient.updateProduct(id, request);
    }

    @DeleteMapping("/{id}")
    public void deleteProduct(@PathVariable Long id) {
        catalogAdminClient.deleteProduct(id);
    }
}
