package com.shopcloud.checkout.client;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
public class CatalogClient {

    private final RestTemplate restTemplate;

    @Value("${shopcloud.services.catalog-url}")
    private String catalogUrl;

    @Value("${shopcloud.internal-token}")
    private String internalToken;

    public CatalogClient(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public ProductDto getProduct(Long productId) {
        HttpEntity<Void> entity = new HttpEntity<>(headers());
        ResponseEntity<ProductDto> response = restTemplate.exchange(
                catalogUrl + "/internal/products/" + productId,
                HttpMethod.GET,
                entity,
                ProductDto.class
        );
        return response.getBody();
    }

    public void decreaseStock(Long productId, Integer quantity) {
        HttpEntity<StockChangeRequest> entity = new HttpEntity<>(new StockChangeRequest(quantity), headers());
        restTemplate.exchange(
                catalogUrl + "/internal/products/" + productId + "/decrease-stock",
                HttpMethod.POST,
                entity,
                ProductDto.class
        );
    }

    private HttpHeaders headers() {
        HttpHeaders headers = new HttpHeaders();
        headers.set("X-Internal-Token", internalToken);
        return headers;
    }
}
