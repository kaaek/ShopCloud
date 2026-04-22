package com.shopcloud.cart.controller;

import com.shopcloud.cart.dto.AddCartItemRequest;
import com.shopcloud.cart.dto.CartDto;
import com.shopcloud.cart.dto.UpdateCartItemRequest;
import com.shopcloud.cart.service.CartService;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseCookie;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.time.Duration;
import java.util.UUID;

@RestController
@RequestMapping("/api/cart")
@RequiredArgsConstructor
public class CartController {
    private final CartService cartService;

    @Value("${cart.cookie.name:SHOPCLOUD_CART_SESSION}")
    private String cartCookieName;

    @Value("${cart.cookie.secure:false}")
    private boolean secureCookie;

    @Value("${cart.cookie.max-age-days:30}")
    private long cookieMaxAgeDays;

    @GetMapping
    public CartDto getCart(
            @CookieValue(value = "${cart.cookie.name:SHOPCLOUD_CART_SESSION}", required = false) String cookieSessionId,
            @RequestHeader(value = "X-Cart-Session-Id", required = false) String headerSessionId,
            HttpServletResponse response
    ) {
        String sessionId = resolveSessionId(cookieSessionId, headerSessionId, response);
        return cartService.getCart(sessionId);
    }

    @PostMapping("/items")
    @ResponseStatus(HttpStatus.CREATED)
    public CartDto addItem(
            @CookieValue(value = "${cart.cookie.name:SHOPCLOUD_CART_SESSION}", required = false) String cookieSessionId,
            @RequestHeader(value = "X-Cart-Session-Id", required = false) String headerSessionId,
            HttpServletResponse response,
            @Valid @RequestBody AddCartItemRequest request
    ) {
        String sessionId = resolveSessionId(cookieSessionId, headerSessionId, response);
        return cartService.addItem(sessionId, request);
    }

    @PutMapping("/items/{productId}")
    public CartDto updateItemQuantity(
            @CookieValue(value = "${cart.cookie.name:SHOPCLOUD_CART_SESSION}", required = false) String cookieSessionId,
            @RequestHeader(value = "X-Cart-Session-Id", required = false) String headerSessionId,
            HttpServletResponse response,
            @PathVariable Long productId,
            @Valid @RequestBody UpdateCartItemRequest request
    ) {
        String sessionId = resolveSessionId(cookieSessionId, headerSessionId, response);
        return cartService.updateItemQuantity(sessionId, productId, request);
    }

    @DeleteMapping("/items/{productId}")
    public CartDto removeItem(
            @CookieValue(value = "${cart.cookie.name:SHOPCLOUD_CART_SESSION}", required = false) String cookieSessionId,
            @RequestHeader(value = "X-Cart-Session-Id", required = false) String headerSessionId,
            HttpServletResponse response,
            @PathVariable Long productId
    ) {
        String sessionId = resolveSessionId(cookieSessionId, headerSessionId, response);
        return cartService.removeItem(sessionId, productId);
    }

    @DeleteMapping("/items")
    public CartDto clearCart(
            @CookieValue(value = "${cart.cookie.name:SHOPCLOUD_CART_SESSION}", required = false) String cookieSessionId,
            @RequestHeader(value = "X-Cart-Session-Id", required = false) String headerSessionId,
            HttpServletResponse response
    ) {
        String sessionId = resolveSessionId(cookieSessionId, headerSessionId, response);
        return cartService.clearCart(sessionId);
    }

    @DeleteMapping
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteCart(
            @CookieValue(value = "${cart.cookie.name:SHOPCLOUD_CART_SESSION}", required = false) String cookieSessionId,
            @RequestHeader(value = "X-Cart-Session-Id", required = false) String headerSessionId,
            HttpServletResponse response
    ) {
        String sessionId = resolveSessionId(cookieSessionId, headerSessionId, response);
        cartService.deleteCart(sessionId);
        expireCartCookie(response);
    }

    private String resolveSessionId(String cookieSessionId, String headerSessionId, HttpServletResponse response) {
        if (StringUtils.hasText(cookieSessionId)) {
            return cookieSessionId;
        }

        String sessionId = StringUtils.hasText(headerSessionId)
                ? headerSessionId
                : UUID.randomUUID().toString();

        addCartCookie(response, sessionId);
        return sessionId;
    }

    private void addCartCookie(HttpServletResponse response, String sessionId) {
        ResponseCookie cookie = ResponseCookie.from(cartCookieName, sessionId)
                .httpOnly(true)
                .secure(secureCookie)
                .sameSite("Lax")
                .path("/")
                .maxAge(Duration.ofDays(cookieMaxAgeDays))
                .build();

        response.addHeader(HttpHeaders.SET_COOKIE, cookie.toString());
    }

    private void expireCartCookie(HttpServletResponse response) {
        ResponseCookie cookie = ResponseCookie.from(cartCookieName, "")
                .httpOnly(true)
                .secure(secureCookie)
                .sameSite("Lax")
                .path("/")
                .maxAge(Duration.ZERO)
                .build();

        response.addHeader(HttpHeaders.SET_COOKIE, cookie.toString());
    }
}
