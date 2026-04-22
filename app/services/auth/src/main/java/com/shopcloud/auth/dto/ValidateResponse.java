package com.shopcloud.auth.dto;

import com.shopcloud.auth.enums.UserRole;

public record ValidateResponse(
        boolean valid,
        String email,
        UserRole role
) {
}