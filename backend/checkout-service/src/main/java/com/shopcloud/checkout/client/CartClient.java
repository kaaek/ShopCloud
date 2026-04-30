package com.shopcloud.checkout.client;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.util.List;

@Component
public class CartClient {

    private final RestTemplate restTemplate;

    @Value("${shopcloud.services.cart-url}")
    private String cartUrl;

    @Value("${shopcloud.internal-token}")
    private String internalToken;

    public CartClient(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public List<CartItemDto> getCart(Long userId) {
        HttpEntity<Void> entity = new HttpEntity<>(headers());
        ResponseEntity<List<CartItemDto>> response = restTemplate.exchange(
                cartUrl + "/internal/carts/users/" + userId,
                HttpMethod.GET,
                entity,
                new ParameterizedTypeReference<List<CartItemDto>>() {}
        );
        return response.getBody();
    }

    public void clearCart(Long userId) {
        HttpEntity<Void> entity = new HttpEntity<>(headers());
        restTemplate.exchange(
                cartUrl + "/internal/carts/users/" + userId,
                HttpMethod.DELETE,
                entity,
                Void.class
        );
    }

    private HttpHeaders headers() {
        HttpHeaders headers = new HttpHeaders();
        headers.set("X-Internal-Token", internalToken);
        return headers;
    }
}
