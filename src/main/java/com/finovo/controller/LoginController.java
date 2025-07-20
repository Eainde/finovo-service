package com.finovo.controller;

import com.finovo.controller.request.LoginRequest;
import com.finovo.controller.response.LoginResponse;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/login")
@CrossOrigin(origins = "*")
public class LoginController {

  @PostMapping("/")
  public Mono<LoginResponse> login(@RequestBody LoginRequest loginRequest) {
    return Mono.just(LoginResponse.builder().token("abcdef").email(loginRequest.getUsername()).build());
  }
}
