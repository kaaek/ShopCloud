package com.shopcloud.cart.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.repository.configuration.EnableRedisRepositories;

@Configuration
@EnableRedisRepositories(basePackages = "com.shopcloud.cart.repo")
public class RedisConfig {
}
