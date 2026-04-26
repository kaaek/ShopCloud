package com.shopcloud.admin.client;

import com.shopcloud.admin.dto.ProductDto;
import com.shopcloud.admin.dto.ProductRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.util.List;

@Component
public class CatalogAdminClient {

    private final RestTemplate restTemplate;

    @Value("${shopcloud.services.catalog-url}")
    private String catalogUrl;

    @Value("${shopcloud.internal-token}")
    private String internalToken;

    public CatalogAdminClient(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public List<ProductDto> allProducts() {
        ResponseEntity<List<ProductDto>> response = restTemplate.exchange(
                catalogUrl + "/internal/products",
                HttpMethod.GET,
                new HttpEntity<>(headers()),
                new ParameterizedTypeReference<List<ProductDto>>() {}
        );
        return response.getBody();
    }

    public ProductDto createProduct(ProductRequest request) {
        ResponseEntity<ProductDto> response = restTemplate.exchange(
                catalogUrl + "/internal/products",
                HttpMethod.POST,
                new HttpEntity<>(request, headers()),
                ProductDto.class
        );
        return response.getBody();
    }

    public ProductDto updateProduct(Long id, ProductRequest request) {
        ResponseEntity<ProductDto> response = restTemplate.exchange(
                catalogUrl + "/internal/products/" + id,
                HttpMethod.PUT,
                new HttpEntity<>(request, headers()),
                ProductDto.class
        );
        return response.getBody();
    }

    public void deleteProduct(Long id) {
        restTemplate.exchange(
                catalogUrl + "/internal/products/" + id,
                HttpMethod.DELETE,
                new HttpEntity<>(headers()),
                Void.class
        );
    }

    private HttpHeaders headers() {
        HttpHeaders headers = new HttpHeaders();
        headers.set("X-Internal-Token", internalToken);
        headers.setContentType(MediaType.APPLICATION_JSON);
        return headers;
    }
}
