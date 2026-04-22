package com.shopcloud.catalog.entity;
import com.shopcloud.catalog.enums.*;
import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;

@Entity
@Table(name = "products")
@Data // Generates getters, setters, toString, equals, hashCode
@NoArgsConstructor // Required by JPA for instantiation
@AllArgsConstructor // Generates constructor with all fields
@Builder // Enables builder pattern for convenient object creation
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    @NonNull
    private String productName;

    @Column(nullable = false, unique = false)
    private String productDescription;

    @Column(nullable = false, unique = false)
    @NonNull
    @Enumerated(EnumType.STRING)
    private ProductStatus productStatus;

    @Column(nullable = false, unique = false)
    @NonNull
    @Enumerated(EnumType.STRING)
    private ProductCategory productCategory;

    @Column(nullable = false, unique = false)
    @NonNull
    @Enumerated(EnumType.STRING)
    private ProductRating productRating;

    @Column(nullable=false, unique = false)
    private BigDecimal productPrice; // double cannot be null, @NonNull is redundant so it is omitted.

    @Column(nullable=false, unique=false)
    @NonNull
    private int productQuantity;

    @Column(nullable = false, length = 1024)
    @NonNull
    private String productImageUrl;
}   