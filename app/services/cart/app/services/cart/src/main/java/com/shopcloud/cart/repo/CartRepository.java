package com.shopcloud.cart.repo;

import com.shopcloud.cart.entity.Cart;
import org.springframework.data.repository.CrudRepository;

public interface CartRepository extends CrudRepository<Cart, String> {
}
