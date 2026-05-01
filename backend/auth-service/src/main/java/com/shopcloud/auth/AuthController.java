package com.shopcloud.auth;

import com.shopcloud.auth.dto.AuthResponse;
import com.shopcloud.auth.dto.LoginRequest;
import com.shopcloud.auth.dto.RegisterRequest;
import com.shopcloud.auth.dto.UserMeResponse;
import com.shopcloud.auth.security.JwtService;
import com.shopcloud.auth.user.AppUser;
import com.shopcloud.auth.user.Role;
import com.shopcloud.auth.user.UserRepository;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    @Value("${shopcloud.admin-bootstrap-key}")
    private String adminBootstrapKey;

    public AuthController(UserRepository userRepository,
                          PasswordEncoder passwordEncoder,
                          JwtService jwtService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    @PostMapping("/register")
    public AuthResponse registerCustomer(@Valid @RequestBody RegisterRequest request) {
        return register(request, Role.CUSTOMER);
    }

    @PostMapping("/admin/register")
    public AuthResponse registerAdmin(@RequestHeader("X-Admin-Bootstrap-Key") String bootstrapKey,
                                      @Valid @RequestBody RegisterRequest request) {
        if (!adminBootstrapKey.equals(bootstrapKey)) {
            throw new IllegalArgumentException("Invalid admin bootstrap key");
        }
        return register(request, Role.ADMIN);
    }

    @PostMapping("/login")
    public AuthResponse loginCustomer(@Valid @RequestBody LoginRequest request) {
        return login(request, Role.CUSTOMER);
    }

    @PostMapping("/admin/login")
    public AuthResponse loginAdmin(@Valid @RequestBody LoginRequest request) {
        return login(request, Role.ADMIN);
    }

    @GetMapping("/me")
    public UserMeResponse me(Authentication authentication) {
        Long userId = (Long) authentication.getDetails();
        String email = authentication.getName();
        String role = authentication.getAuthorities().iterator().next().getAuthority().replace("ROLE_", "");
        return new UserMeResponse(userId, email, role);
    }

    private AuthResponse register(RegisterRequest request, Role role) {
        String normalizedEmail = request.getEmail().trim().toLowerCase();

        if (userRepository.existsByEmail(normalizedEmail)) {
            throw new IllegalArgumentException("Email already exists");
        }

        AppUser user = new AppUser(
                request.getFullName(),
                normalizedEmail,
                passwordEncoder.encode(request.getPassword()),
                role
        );
        AppUser saved = userRepository.save(user);
        return responseFor(saved);
    }

    private AuthResponse login(LoginRequest request, Role expectedRole) {
        String normalizedEmail = request.getEmail().trim().toLowerCase();

        AppUser user = userRepository.findByEmail(normalizedEmail)
                .orElseThrow(() -> new IllegalArgumentException("Invalid email or password"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new IllegalArgumentException("Invalid email or password");
        }

        if (user.getRole() != expectedRole) {
            throw new IllegalArgumentException("Wrong login endpoint for this account type");
        }

        return responseFor(user);
    }

    private AuthResponse responseFor(AppUser user) {
        String token = jwtService.generateToken(user);
        return new AuthResponse(token, user.getId(), user.getEmail(), user.getRole().name());
    }
}
