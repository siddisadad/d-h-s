# Spring Boot CORS Setup Guide

To allow the Flutter web application to communicate with your Spring Boot backend, you must enable **Cross-Origin Resource Sharing (CORS)**. 

### 🛡️ Recommended Security Configuration

Add the following `@Bean` to your **Security Configuration** class (usually where you configure `SecurityFilterChain`).

```java
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

@Configuration
public class WebSecurityConfig {

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        
        // Allow your Flutter Web development port
        configuration.setAllowedOrigins(Arrays.asList("http://localhost:8081")); 
        
        // Allow all standard REST methods
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"));
        
        // Allow JWT and Content-Type headers
        configuration.setAllowedHeaders(Arrays.asList("Authorization", "Content-Type", "X-Requested-With"));
        
        // Allow the browser to send credentials (cookies, auth headers)
        configuration.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", source);
        return source;
    }
}
```

### 🔍 Why is this necessary?
By default, web browsers block requests made to a different domain/port than the one hosting the app (e.g., `localhost:8081` calling `localhost:8080`). This is a security feature. The server must explicitly "vouch" for the client by sending the correct CORS headers in response to the browser's "preflight" OPTIONS request.

### 🛠️ Verification
Once applied, the browser console will no longer show `XMLHttpRequest onError` and your network requests in the **Network Tab** should show a green `200 OK` or `201 Created` status.
