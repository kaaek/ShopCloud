package com.shopcloud.auth.service;

import com.shopcloud.auth.dto.AuthResponse;
import com.shopcloud.auth.dto.LoginRequest;
import com.shopcloud.auth.dto.LogoutRequest;
import com.shopcloud.auth.dto.RefreshRequest;
import com.shopcloud.auth.dto.RegisterRequest;
import com.shopcloud.auth.dto.ValidateResponse;
import com.shopcloud.auth.entity.User;
import com.shopcloud.auth.enums.UserRole;
import com.shopcloud.auth.security.JwtService;
import com.shopcloud.auth.security.TokenBlacklistService;
import java.time.Instant;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.server.ResponseStatusException;

import static org.springframework.http.HttpStatus.BAD_REQUEST;
import static org.springframework.http.HttpStatus.UNAUTHORIZED;

@Service
public class AuthService {

    private final UserService userService;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final TokenBlacklistService tokenBlacklistService;

    public AuthService(
            UserService userService,
            PasswordEncoder passwordEncoder,
            JwtService jwtService,
            TokenBlacklistService tokenBlacklistService
    ) {
        this.userService = userService;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.tokenBlacklistService = tokenBlacklistService;
    }

    public AuthResponse register(RegisterRequest request) {
        UserRole role = request.role() == null ? UserRole.CUSTOMER : request.role();
        User user = userService.createUser(request.email(), request.password(), role);
        return createTokenResponse(user);
    }

    public AuthResponse login(LoginRequest request) {
        User user = userService.getByEmail(request.email());

        if (!user.isActive() || !passwordEncoder.matches(request.password(), user.getPassword())) {
            throw new ResponseStatusException(UNAUTHORIZED, "Invalid credentials");
        }

        return createTokenResponse(user);
    }

    public AuthResponse refresh(RefreshRequest request) {
        String refreshToken = request.refreshToken();
        if (tokenBlacklistService.isBlacklisted(refreshToken)) {
            throw new ResponseStatusException(UNAUTHORIZED, "Refresh token has been revoked");
        }

        String subject = jwtService.extractSubject(refreshToken);
        User user = userService.getByEmail(subject);

        if (!jwtService.isTokenValid(refreshToken, user.getEmail(), "refresh")) {
            throw new ResponseStatusException(UNAUTHORIZED, "Invalid refresh token");
        }

        tokenBlacklistService.blacklist(refreshToken, jwtService.extractExpiration(refreshToken).toInstant());
        return createTokenResponse(user);
    }

    public void logout(LogoutRequest request, String authorizationHeader) {
        String accessToken = extractBearerToken(authorizationHeader, false);
        if (StringUtils.hasText(accessToken)) {
            blacklistTokenSafely(accessToken);
        }

        if (request != null && StringUtils.hasText(request.refreshToken())) {
            blacklistTokenSafely(request.refreshToken());
        }
    }

    public ValidateResponse validate(String authorizationHeader) {
        String accessToken = extractBearerToken(authorizationHeader, true);

        if (tokenBlacklistService.isBlacklisted(accessToken)) {
            throw new ResponseStatusException(UNAUTHORIZED, "Token is revoked");
        }

        String email = jwtService.extractSubject(accessToken);
        User user = userService.getByEmail(email);

        if (!jwtService.isTokenValid(accessToken, user.getEmail(), "access")) {
            throw new ResponseStatusException(UNAUTHORIZED, "Invalid token");
        }

        return new ValidateResponse(true, user.getEmail(), user.getRole());
    }

    private AuthResponse createTokenResponse(User user) {
        String accessToken = jwtService.generateAccessToken(user.getEmail(), user.getRole());
        String refreshToken = jwtService.generateRefreshToken(user.getEmail());
        return new AuthResponse(
                accessToken,
                refreshToken,
                "Bearer",
                jwtService.getAccessTokenExpirationSeconds()
        );
    }

    private String extractBearerToken(String authorizationHeader, boolean required) {
        if (!StringUtils.hasText(authorizationHeader) || !authorizationHeader.startsWith("Bearer ")) {
            if (required) {
                throw new ResponseStatusException(BAD_REQUEST, "Authorization header with Bearer token is required");
            }
            return null;
        }
        return authorizationHeader.substring(7);
    }

    private void blacklistTokenSafely(String token) {
        try {
            Instant expiry = jwtService.extractExpiration(token).toInstant();
            tokenBlacklistService.blacklist(token, expiry);
        } catch (Exception ex) {
            throw new ResponseStatusException(BAD_REQUEST, "Token cannot be processed for logout");
        }
    }
}