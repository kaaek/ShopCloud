package com.shopcloud.catalog.dto;

import com.shopcloud.catalog.enums.ProductCategory;
import com.shopcloud.catalog.enums.ProductRating;
import com.shopcloud.catalog.enums.ProductStatus;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProductDto {
    private Long id;

    @NotBlank
    private String productName;

    @NotBlank
    private String productDescription;

    @NotNull
    private ProductStatus productStatus;

    @NotNull
    private ProductCategory productCategory;

    @NotNull
    private ProductRating productRating;

    @NotNull
    @DecimalMin("0.0")
    private BigDecimal productPrice;

    @NotBlank
    @Pattern(
            regexp = "^(https?://).+",
            message = "productImageUrl must start with http:// or https://"
    )
    private String productImageUrl;
}
