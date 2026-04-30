package com.shopcloud.admin.client;

import com.shopcloud.admin.dto.OrderDto;
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
public class CheckoutAdminClient {

    private final RestTemplate restTemplate;

    @Value("${shopcloud.services.checkout-url}")
    private String checkoutUrl;

    @Value("${shopcloud.internal-token}")
    private String internalToken;

    public CheckoutAdminClient(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public List<OrderDto> allOrders() {
        ResponseEntity<List<OrderDto>> response = restTemplate.exchange(
                checkoutUrl + "/internal/orders",
                HttpMethod.GET,
                new HttpEntity<>(headers()),
                new ParameterizedTypeReference<List<OrderDto>>() {}
        );
        return response.getBody();
    }

    public OrderDto markReturned(Long orderId) {
        ResponseEntity<OrderDto> response = restTemplate.exchange(
                checkoutUrl + "/internal/orders/" + orderId + "/return",
                HttpMethod.POST,
                new HttpEntity<>(headers()),
                OrderDto.class
        );
        return response.getBody();
    }

    private HttpHeaders headers() {
        HttpHeaders headers = new HttpHeaders();
        headers.set("X-Internal-Token", internalToken);
        return headers;
    }
}
